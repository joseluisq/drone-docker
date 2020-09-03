local pipeline = import 'pipeline.libsonnet';

[
  pipeline.test('linux', 'amd64'),
  pipeline.build('linux', 'amd64'),
]
