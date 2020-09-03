local testing_pipeline_name = 'testing';
local golang_image_name(os, version) = 'golang:1.15';

{

  // Testing pipeline
  test(os='linux', arch='amd64', version='')::
    local golang = golang_image_name(os, version);
    local volumes = [{ name: 'gopath', path: '/go' }];

    {
      kind: 'pipeline',
      name: testing_pipeline_name,
      platform: {
        os: os,
        arch: arch,
        version: if std.length(version) > 0 then version,
      },
      steps: [
        {
          name: 'vet',
          image: golang,
          pull: 'always',
          environment: {
            GO111MODULE: 'on',
          },
          commands: [
            'go vet ./...',
          ],
          volumes: volumes,
        },
        {
          name: 'test',
          image: golang,
          pull: 'always',
          environment: {
            GO111MODULE: 'on',
          },
          commands: [
            'go test -cover ./...',
          ],
          volumes: volumes,
        },
      ],
      trigger: {
        ref: [
          'refs/heads/master',
          'refs/tags/**',
          'refs/pull/**',
        ],
      },
      volumes: [{ name: 'gopath', temp: {} }],
    },

  // Building pipeline
  build(os='linux', arch='amd64', version='')::
    local tag = os + '-' + arch;
    local file_suffix = std.strReplace(tag, '-', '.');
    local volumes = [];
    local golang = golang_image_name(os, version);
    local plugin_repo = 'plugins';
    local depends_on = [testing_pipeline_name];

    {
      kind: 'pipeline',
      name: tag,
      platform: {
        os: os,
        arch: arch,
        version: if std.length(version) > 0 then version,
      },
      steps: [
        {
          name: 'build-push',
          image: golang,
          pull: 'always',
          environment: {
            CGO_ENABLED: '0',
            GO111MODULE: 'on',
          },
          commands: [
            'go build -v -ldflags "-X main.version=${DRONE_COMMIT_SHA:0:8}" -a -tags netgo -o release/' + os + '/' + arch + '/drone-docker ./cmd/drone-docker',
          ],
          when: {
            event: {
              exclude: ['tag'],
            },
          },
        },
        {
          name: 'build-tag',
          image: golang,
          pull: 'always',
          environment: {
            CGO_ENABLED: '0',
            GO111MODULE: 'on',
          },
          commands: [
            'go build -v -ldflags "-X main.version=${DRONE_TAG##v}" -a -tags netgo -o release/' + os + '/' + arch + '/drone-docker ./cmd/drone-docker',
          ],
          when: {
            event: ['tag'],
          },
        },
        {
          name: 'executable',
          image: golang,
          pull: 'always',
          commands: [
            './release/' + os + '/' + arch + '/drone-docker' + ' --help',
          ],
        },
        {
          name: 'dryrun',
          image: 'plugins/docker:' + tag,
          pull: 'always',
          settings: {
            dry_run: true,
            tags: tag,
            dockerfile: 'docker/' + 'Dockerfile.' + file_suffix,
            daemon_off: 'false',
            repo: plugin_repo,
            username: { from_secret: 'docker_username' },
            password: { from_secret: 'docker_password' },
          },
          volumes: if std.length(volumes) > 0 then volumes,
          when: {
            event: ['pull_request'],
          },
        },
        {
          name: 'publish',
          image: 'plugins/docker:' + tag,
          pull: 'always',
          settings: {
            auto_tag: true,
            auto_tag_suffix: tag,
            daemon_off: 'false',
            dockerfile: 'docker/' + 'Dockerfile.' + file_suffix,
            repo: plugin_repo,
            username: { from_secret: 'docker_username' },
            password: { from_secret: 'docker_password' },
          },
          volumes: if std.length(volumes) > 0 then volumes,
          when: {
            event: {
              exclude: ['pull_request'],
            },
          },
        },
      ],
      trigger: {
        ref: [
          'refs/heads/master',
          'refs/tags/**',
          'refs/pull/**',
        ],
      },
      depends_on: depends_on,
    },

}
