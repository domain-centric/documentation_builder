[//]: # (This file was generated from: doc/template/doc/wiki/02-Getting-Started.md.template using the documentation_builder package)

## Step by step
* Read the [Wiki documentation](https://github.com/domain-centric/documentation_builder/wiki)
* [Install the documentation_builder package](https://pub.dev/packages/documentation_builder/install) in your project
* Add a build.yaml file to the root of your project with the following lines (merge lines if build.yaml file already exists):
  ```
  targets:
    $default:
      sources:
        - doc/**
        - lib/**
        - bin/**
        - test/**
        - pubspec.*
        - $package$
  ```
  For more information on the build.yaml file see [build_config](https://pub.dev/documentation/build_config/latest/)
* Create 'doc/template' folders in the root of your project
* Create template files in the "doc/template" folder. See [examples](https://pub.dev/packages/documentation_builder/example)
* [Generate the documentation files](https://github.com/domain-centric/documentation_builder/wiki08-Generating.md)
* [Publish the documentation files](https://github.com/domain-centric/documentation_builder/wiki09-Publishing.md)

## Build configuration
[documentation_builder](https://pub.dev/packages/documentation_builder) build options have default values.
You can override these default values by adding the following lines to the defaults section of a build.yaml file (merge these lines if build.yaml file already exists):
```
targets:
  $default:
    builders:
      documentation_builder:
        options:
          inputPath: #your input expression, see the default value for inspiration
          outputPath: #your output expression, see the default value for inspiration
          fileHeaders: #your fileHeaders expression, see the default value for inspiration
```
For more information on the build.yaml file see [build_config](https://pub.dev/documentation/build_config/latest/)

### Build option parameter: inputPath
* Description: An expression where to find template files
* Default value: `'doc/template/{{filePath}}.template'`

### Build option parameter: outputPath
* Description: An expression where to store the result files
* Default value: `'{{filePath}}'`

### Build option parameter: fileHeaders
* Description: A map of file suffixes and the file header template to be added (which can be null)
* Default value:
  ```
  {
  'LICENSE': null,
  'LICENSE.md': null,
  '.md':
      '[//](https://pub.dev/packages///): # (This file was generated from: {{inputPath()}} using the documentation_builder package)&#92;n&#92;r',
  '.dart':
      'This file was generated from: {{inputPath()}} using the documentation_builder package&#92;n&#92;r'
  }
  ```