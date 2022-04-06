// 🌎 Project imports:
import '../models/plots.model.dart';

extension JoiningPlots on Plots {
  /// join method will return the plots as co-ordinates
  String join() => '($x, $y)';
}

extension ListString on List<Plots> {
  /// join method will return the plots as co-ordinates
  String join() {
    String result = '';
    forEach((Plots element) {
      result += element.join();
    });
    return result;
  }
}
