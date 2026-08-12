import 'package:fpdart/fpdart.dart';
import '../domain/entities/person.dart';
import '../data/repositories/person_repository.dart';

class PersonService {
  final PersonRepository repository;

  PersonService(this.repository);

  Future<Either<String, List<PersonEntity>>> getPersons() {
    return repository.getPersons();
  }

  Future<Either<String, PersonEntity>> getPersonById(int id) {
    return repository.getPersonById(id);
  }

  Future<Either<String, int>> addPerson(PersonEntity person) {
    if (person.name.trim().isEmpty) {
      return Future.value(left('El nombre es obligatorio.'));
    }
    return repository.addPerson(person);
  }

  Future<Either<String, int>> updatePerson(PersonEntity person) {
    if (person.name.trim().isEmpty) {
      return Future.value(left('El nombre es obligatorio.'));
    }
    return repository.updatePerson(person);
  }

  Future<Either<String, int>> deletePerson(int id) {
    return repository.deletePerson(id);
  }
}
