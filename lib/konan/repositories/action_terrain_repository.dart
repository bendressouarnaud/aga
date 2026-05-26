import '../dao/action_terrain_dao.dart';
import '../model/action_terrain.dart';
import '../model/artisan.dart';

class ActionTerrainRepository {
  final dao = ActionTerrainDao();

  Future<int> insert(ActionTerrain data) => dao.create(data);
  Future<int> update(ActionTerrain data) => dao.update(data);
  Future<List<ActionTerrain>> findAll() => dao.findAll();
}