import './edit_state_owner.dart' as editOwners;
import './edit_state_buildings.dart' as editStateBuildings;

void main(List<String> args) async {
  await editOwners.main();
  await editStateBuildings.main();
}
