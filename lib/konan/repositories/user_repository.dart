
import '../dao/user_dao.dart';
import '../model/user.dart';

class UserRepository {
  final userDao = UserDao();

  Future<int> insertUser(User user) => userDao.createUser(user);
  Future<int> update(User user) => userDao.update(user);
  Future<User?>  findLocalUser() => userDao.findLocalUser();
}