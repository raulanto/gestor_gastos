import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/person_service.dart';
import '../../data/datasources/person_local_data_source.dart';
import '../../data/repositories/person_repository.dart';
import '../../domain/entities/person.dart';

import '../../../../core/database/app_database.dart';

final personLocalDataSourceProvider = Provider<PersonLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PersonLocalDataSource(db);
});

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final localDataSource = ref.watch(personLocalDataSourceProvider);
  return PersonRepository(localDataSource);
});

final personServiceProvider = Provider<PersonService>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return PersonService(repository);
});

final personsProvider = AsyncNotifierProvider<PersonsNotifier, List<PersonEntity>>(() {
  return PersonsNotifier();
});

class PersonsNotifier extends AsyncNotifier<List<PersonEntity>> {
  @override
  Future<List<PersonEntity>> build() async {
    return _fetchPersons();
  }

  Future<List<PersonEntity>> _fetchPersons() async {
    final personService = ref.watch(personServiceProvider);
    final result = await personService.getPersons();
    return result.fold(
      (error) => throw Exception(error),
      (persons) => persons,
    );
  }

  Future<void> loadPersons() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPersons());
  }

  Future<void> addPerson(PersonEntity person) async {
    final personService = ref.read(personServiceProvider);
    final result = await personService.addPerson(person);
    result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
      (_) => loadPersons(),
    );
  }

  Future<void> updatePerson(PersonEntity person) async {
    final personService = ref.read(personServiceProvider);
    final result = await personService.updatePerson(person);
    result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
      (_) => loadPersons(),
    );
  }

  Future<void> deletePerson(int id) async {
    final personService = ref.read(personServiceProvider);
    final result = await personService.deletePerson(id);
    result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
      (_) => loadPersons(),
    );
  }
}
