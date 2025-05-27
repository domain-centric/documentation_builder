[//]: # (This file was generated from: doc/template/doc/wiki/02-Getting-Started.md.template using the documentation_builder package)
## Step by step
* Read the [Wiki documentation](https://github.com/domain-centric/documentation_builder/wiki)
* Install [documentation_builder](https://pub.dev/packages/documentation_builder) developer dependencies in  in your project:
  ```
  dart pub add --dev build_runner
  dart pub add --dev documentation_builder
  ```
  [build_runner](https://pub.dev/packages/build_runner) is a tool to run file generators like [documentation_builder](https://pub.dev/packages/documentation_builder)
* Configure the documentation_builder (optionally)
The following is only needed when your project already has a build.yaml file or when you want to override the options:
Add a build.yaml file to the root of your project with the following lines (or merge lines if build.yaml file already exists):
  ```
  targets:
    $default:
      builders:
        documentation_builder|documentation_builder:
          enabled: True
          # options:
            # input_path:
              # An expression where to find template files
              # Defaults to 'doc/template/{{filePath}}.template'
            # output_path:
              # An expression where to store the result files
              # Defaults to '{{filePath}}'
            # file_headers:
              # A map of file output suffixes and the file header template to be added (which can be null),
              # Defaults to:
              #   {
              #    'LICENSE': null,
              #    'LICENSE.md': null,
              #    '.md': '[//](https://pub.dev/packages///): # (This file was generated from: {{inputPath()}} using the documentation_builder package)',
              #    '.dart': '// This file was generated from: {{inputPath()}} using the documentation_builder package'
              #   }
  ```
  For more information on the build.yaml file see [build_config](https://pub.dev/documentation/build_config/latest/)
* Create 'doc/template' folders in the root of your project
* Create template files in the "doc/template" folder. See [examples](https://github.com/domain-centric/documentation_builder/wiki/10-Examples)
* [Generate the documentation files](https://github.com/domain-centric/documentation_builder/wiki/08-Generating)
* [Publish the documentation files](https://github.com/domain-centric/documentation_builder/wiki/09-Publishing)
