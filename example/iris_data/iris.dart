import 'dart:io';
import 'package:k_means_cluster/k_means_cluster.dart';

main() async {
  // Load the data from iris.csv; ignore header-line;
  // each line represents an instance of an iris.
  List<String> lines =
      (await File("example/iris_data/iris.csv").readAsLines()).sublist(1);

  // Set the distance measure; this can be any function of the form
  // num f(List<num> a, List<num> b): a and b contain the coordinates
  // of two instances; f returns a numerical distance between the
  // points.
  distanceMeasure = DistanceType.squaredEuclidean;

  // Create the list of instances.
  List<Instance> instances = lines.map((String line) {
    List<String> datum = line.split(",");

    // The first four columns contain the coordinates.
    final location =
        datum.sublist(0, 4).map((String x) => num.parse(x)).toList();

    // The fifth column contains the species.
    final id = datum[4];

    return Instance(location: location, id: id);
  }).toList();

  // Randomly create the initial clusters.
  List<Cluster> clusters = initialClusters(3, instances, seed: 0);

  // Run the algorithm.
  var info = kMeans(clusters: clusters, instances: instances);
  print(info);

  // See the final cluster results.
  clusters.forEach((cluster) {
    print(cluster);
    cluster.instances.forEach((iris) {
      print("  - $iris");
    });
  });
}
