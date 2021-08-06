import 'dart:io';

main() async {
  // TODO create shell class, e.g.:
  // e.g. Shell.run('''
  // flutter packages pub run build_runner clean
  // flutter packages pub run build_runner build --delete-conflicting-outputs
  // ''', continueAfterError:false);
  //  or maybe there is an existing shell package?

  var result=await Process.run(
    'flutter',
    ['pub', 'run', 'build_runner', 'clean'],
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  result=await Process.run(
    'flutter',
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}
