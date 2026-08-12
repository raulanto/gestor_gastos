import 'package:fpdart/fpdart.dart';
import '../../domain/entities/person.dart';
import '../datasources/person_local_data_source.dart';

class PersonRepository {
  final PersonLocalDataSource localDataSource;

  PersonRepository(this.localDataSource);

  Future<Either<String, List<PersonEntity>>> getPersons() async {
    try {
      final persons = await localDataSource.getPersons();
      return right(persons);
    } catch (e) {
      return left('Error al obtener las personas: $e');
    }
  }

  Future<Either<String, PersonEntity>> getPersonById(int id) async {
    try {
      final person = await localDataSource.getPersonById(id);
      if (person != null) {
        return right(person);
      } else {
        return left('Persona no encontrada');
      }
    } catch (e) {
      return left('Error al obtener la persona: $e');
    }
  }

  Future<Either<String, int>> addPerson(PersonEntity person) async {
    try {
      final id = await localDataSource.insertPerson(person);
      return right(id);
    } catch (e) {
      return left('Error al guardar la persona: $e');
    }
  }

  Future<Either<String, int>> updatePerson(PersonEntity person) async {
    try {
      final rowsAffected = await localDataSource.updatePerson(person);
      return right(rowsAffected);
    } catch (e) {
      return left('Error al actualizar la persona: $e');
    }
  }

  Future<Either<String, int>> deletePerson(int id) async {
    try {
      final rowsAffected = await localDataSource.deletePerson(id);
      return right(rowsAffected);
    } catch (e) {
      return left('Error al eliminar la persona: $e');
    }
  }
}
