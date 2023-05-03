import './edit_state_owner.dart' as editOwners;
import './edit_state_manpower.dart' as editStateManPower;
import './edit_state_resources.dart' as editStateResources;
import './edit_state_buildings.dart' as editStateBuildings;

void main(List<String> args) async {
  await editOwners.main();
  await editStateManPower.main();
  await editStateBuildings.main();
  await editStateResources.main();
}
