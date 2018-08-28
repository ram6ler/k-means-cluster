# k-means-cluster

A very simple implementation of k-means clustering.

## Usage

A clustering session typically involves:

* Setting a distance measurement to use.

```dart
distanceMeasure = DistanceType.squaredEuclidian; // default
```

* Creating a `List` of `Instance`s. This is generally done by mapping a list of whatever data structures is available.

```dart
// For example, data might be a List<String> such
// that each String represents an individual instance.
List<Instance> instances = data.map((datum) {
  List<num> coordinates = ...;
  String id = ...;
  return Instance(coordinates, id: id); 
}).tolist();
```

* Creating a `List` of `Cluster`s. This can be done manually (e.g. create a set of randomly placed clusters). A convenience function `initialClusters` exists that takes in the list of `Instances` already created and randomly generates clusters from the instances such that instances more distant to the previous cluster are more likely to seed the next cluster.

```dart
List<Cluster> clusters = initialClusters(3, instances, seed: 0);
```

* Running the algorithm using the `kmeans` function. This is a side-effect heavy function that iteratively shifts the clusters towards the mean position of the associated instances and reassigns instances to the nearest cluster.

```dart
kmeans(clusters: clusters, instances: instances);
```

* Inspecting the `instances` property of each cluster.

```dart
clusters.forEach((cluster) {
  print(cluster);
  cluster.instances.forEach((instance) {
    print("  - $instance");
  });
});
``` 



Please see the [associated wiki][wiki] for more details and examples.

Please file feature requests and bugs at the [issue tracker][tracker].

[wiki]: https://bitbucket.org/ram6ler/k_means_cluster/wiki/Home
[tracker]: https://bitbucket.org/ram6ler/k_means_cluster/issues
