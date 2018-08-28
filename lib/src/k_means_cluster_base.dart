import 'dart:math' show Random;

/// A function that resurns a distance measure between two points [a]
/// and [b] in space.
typedef num DistanceMeasure(List<num> a, List<num> b);

/// A convenience container class that stores commonly used
/// [DistanceMeasure] functions.
abstract class DistanceType {
  static DistanceMeasure squaredEuclidian = (List<num> a, List<num> b) =>
      List<num>.generate(a.length, (i) => (a[i] - b[i]) * (a[i] - b[i]))
          .fold(0.0, (a, b) => a + b);
  static DistanceMeasure cityBlock = (List<num> a, List<num> b) =>
      List<num>.generate(a.length, (i) => (a[i] - b[i]).abs())
          .fold(0.0, (a, b) => a + b);
}

/// A precision measure; a cluster is considered to have shifted
/// if at least one of its coordinates has changed by more than
/// this amount.
num precision = 1E-6;
DistanceMeasure distanceMeasure = DistanceType.squaredEuclidian;

class _Location {
  _Location(this.location);
  List<num> location;

  /// Returns the distance, as defined by [distanceMeasure], between
  /// [this] and [that] item.
  num distanceFrom(_Location that) => distanceMeasure(location, that.location);
}

/// An instance of data.
///
/// Example:
///
///     var a = Instance([0, 3], id: "A"),
///       b = Instance([0, 3], id: "B");
///     print(a.distanceFrom(b));
class Instance extends _Location {
  Instance(List<num> location, {this.id}) : super(location);
  String id;
  Cluster cluster;

  /// Associate [this] instance with the nearest cluster
  /// in [clusters].
  void reallocate(List<Cluster> clusters) {
    num min;
    Cluster argMin;
    for (Cluster c in clusters) {
      num d = distanceFrom(c);
      if (min == null || min > d) {
        min = d;
        argMin = c;
      }
    }
    if (cluster != null) cluster.instances.remove(this);
    cluster = argMin;
    cluster.instances.add(this);
  }

  @override
  String toString() => "instance $id: $location";
}

/// A cluster of instances.
class Cluster extends _Location {
  Cluster(List<num> location, {this.id}) : super(location) {
    instances = List<Instance>();
  }
  String id;
  List<Instance> instances;

  // returns true if shifted
  bool shift() {
    var nextLocation = List<num>.filled(location.length, 0.0);
    int n = 0;
    instances.forEach((Instance instance) {
      for (int i = 0; i < instance.location.length; i++) {
        nextLocation[i] =
            (nextLocation[i] * n + instance.location[i]) / (n + 1);
      }
      n++;
    });
    bool shifted = List<bool>.generate(location.length,
            (i) => (location[i] - nextLocation[i]).abs() < precision)
        .any((x) => !x);
    location = nextLocation;
    return shifted;
  }

  @override
  String toString() => "cluster $id: $location";
}

/// Creates an list of clusters.
///
/// An attempt is made to spread the clusters by making each instance
/// in [instances] a candidate for the next cluster position with an
/// associated probability proportional to the distance from the most
/// recent cluster.
List<Cluster> initialClusters(int k, List<Instance> instances, {int seed}) {
  final Random rand = seed == null ? Random() : Random(seed);

  Cluster nextCluster(Cluster prev, String id) {
    List<num> ds = instances
        .map((Instance instance) => prev?.distanceFrom(instance) ?? 1)
        .toList();
    num sum = ds.fold(0.0, (a, b) => a + b);
    List<num> ps = ds.map((x) => x / sum).toList();
    int instanceIndex = 0;
    num r = rand.nextDouble(), cum = 0;
    while (true) {
      cum += ps[instanceIndex];
      if (cum > r) break;
      instanceIndex++;
    }
    return Cluster(List<num>.from(instances[instanceIndex].location), id: id);
  }

  Cluster prev;
  var clusters =
      List<Cluster>.generate(k, (i) => nextCluster(prev, "cluster[$i]"));

  instances.forEach((instance) {
    instance.reallocate(clusters);
  });
  return clusters;
}

/// Perform the kmeans algorithm.
///
Map<String, dynamic> kmeans(
    {int maxIterations: 10, List<Instance> instances, List<Cluster> clusters}) {
  var info = <String, dynamic>{};
  int i;
  info["cluster-motion"] = <String, List<List<num>>>{};
  for (i = 0; i < maxIterations; i++) {
    List<bool> shifted =
        clusters.map((Cluster cluster) => cluster.shift()).toList();
    //print("...$clusters");
    clusters.forEach((cluster) {
      if (!info["cluster-motion"].containsKey(cluster.id))
        info["cluster-motion"][cluster.id] = List<List<num>>();
      info["cluster-motion"][cluster.id].add(List<num>.from(cluster.location));
    });
    if (shifted.every((x) => !x)) break;
    instances.forEach((Instance instance) {
      instance.reallocate(clusters);
    });
  }

  info["iterations"] = i == maxIterations
      ? "not stable at $maxIterations"
      : "stable after ${i + 1} iterations";

  return info;
}
