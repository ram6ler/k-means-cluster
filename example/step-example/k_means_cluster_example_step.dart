import 'dart:io';
import 'dart:math';
import 'package:k_means_cluster/k_means_cluster.dart';

final cols = ["orange", "purple", "green"];

main() async {
  // generate some random points
  var rand = new Random(0);
  var instances = new List<Instance>.generate(100, (i) {
    int center = rand.nextInt(3);
    num cx, cy;
    switch (center) {
      case 0:
        cx = 4;
        cy = 5;
        break;
      case 1:
        cx = 8;
        cy = 12;
        break;
      default:
        cx = 12;
        cy = 6;
        break;
    }

    num r = 3 * rand.nextDouble(),
        t = 2 * PI * rand.nextDouble(),
        x = cx + r * cos(t),
        y = cy + r * sin(t);
    return new Instance([x, y], id: "[$i]");
  });

  List<Cluster> clusters = initialClusters(3, instances, seed: 1);

  // plot the initial cluster positions and associated points
  await new File("0.svg").writeAsString(svg(clusters));

  // track the progress of the algorithm; save a plot of each stage
  for (int i = 1; i <= 7; i++) {
    kmeans(clusters: clusters, instances: instances, maxIterations: 1);
    await new File("$i.svg").writeAsString(svg(clusters));
  }
}

// a simple svg-plot generator
String svg(List<Cluster> clusters) {
  var sb =
      new StringBuffer('<svg width="250" height="250" viewBox="0 0 15 15">');
  for (int i = 0; i < clusters.length; i++) {
    Cluster cluster = clusters[i];
    num x = cluster.location[0], y = cluster.location[1];
    String col = cols[i];
    sb.writeln(
        '<circle cx="${x.toStringAsFixed(2)}" cy="${y.toStringAsFixed(2)}" r="1" stroke="$col" fill-opacity="0" stroke-width="0.5%" />');
    cluster.instances.forEach((point) {
      num x = point.location[0], y = point.location[1];
      sb.writeln(
          '  <circle cx="${x.toStringAsFixed(2)}" cy="${y.toStringAsFixed(2)}" r="0.1" stroke="$col" fill-opacity="0" stroke-width="0.5%" />');
    });
  }
  sb.writeln("</svg>");
  return sb.toString();
}
