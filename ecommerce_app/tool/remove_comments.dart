import 'dart:io';

/// Command-line utility to remove comments from Dart source files.
/// Usage:
///   dart run tool/remove_comments.dart --apply
/// Without --apply it runs in dry-run mode and prints a summary only.
/// It processes files under the `lib/` directory by default.
/// Optional flags:
///   --path <relative_path>   Root directory to scan (default: lib)
///   --include-tests          Also process test/ directory
///   --backup                 Create .bak copies before modifying
void main(List<String> args) async {
  final argSet = args.toSet();
  final apply = argSet.contains('--apply');
  final includeTests = argSet.contains('--include-tests');
  final backup = argSet.contains('--backup');
  String rootPath = 'lib';
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--path' && i + 1 < args.length) {
      rootPath = args[i + 1];
    }
  }

  final roots = <Directory>[Directory(rootPath)];
  if (includeTests) roots.add(Directory('test'));

  final dartFiles = <File>[];
  for (final dir in roots) {
    if (!dir.existsSync()) continue;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        dartFiles.add(entity);
      }
    }
  }

  int totalCommentsRemoved = 0;
  int filesChanged = 0;

  for (final file in dartFiles) {
    final original = await file.readAsString();
    final stripped = _stripComments(original);
    if (original != stripped) {
      filesChanged++;
      totalCommentsRemoved += _countRemovedComments(original, stripped);
      if (apply) {
        if (backup) {
          final backupFile = File('${file.path}.bak');
          await backupFile.writeAsString(original);
        }
        await file.writeAsString(stripped);
      }
    }
  }

  stdout.writeln('Files scanned: ${dartFiles.length}');
  stdout.writeln('Files with changes: $filesChanged');
  stdout.writeln('Approx comment tokens removed: $totalCommentsRemoved');
  if (!apply) {
    stdout.writeln('Dry run complete. Re-run with --apply to modify files.');
  } else {
    stdout.writeln('Comments removed.');
  }
}

/// Counts approximate removed comment tokens by comparing occurrences of // and /* */.
int _countRemovedComments(String before, String after) {
  int countTokens(String s) {
    final single = RegExp(r'//');
    final multiStart = RegExp(r'/\*');
    return single.allMatches(s).length + multiStart.allMatches(s).length;
  }

  final b = countTokens(before);
  final a = countTokens(after);
  return b - a;
}

/// Removes // line comments and /* */ block comments while preserving string contents.
String _stripComments(String input) {
  final buffer = StringBuffer();
  bool inSingleLineComment = false;
  bool inBlockComment = false;
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool inTripleSingle = false;
  bool inTripleDouble = false;
  bool escaped = false;

  int i = 0;
  while (i < input.length) {
    final char = input[i];
    final next = i + 1 < input.length ? input[i + 1] : '';
    final next2 = i + 2 < input.length ? input[i + 2] : '';

    // Handle end of single-line comment
    if (inSingleLineComment) {
      if (char == '\n') {
        inSingleLineComment = false;
        buffer.write(char); // keep newline
      }
      i++;
      continue;
    }

    // Handle end of block comment
    if (inBlockComment) {
      if (char == '*' && next == '/') {
        inBlockComment = false;
        i += 2;
        continue;
      }
      i++;
      continue;
    }

    // If inside a string, just copy and manage escapes.
    if (inSingleQuote || inDoubleQuote || inTripleSingle || inTripleDouble) {
      buffer.write(char);
      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (inSingleQuote && char == '\'') {
        inSingleQuote = false;
      } else if (inDoubleQuote && char == '"') {
        inDoubleQuote = false;
      } else if (inTripleSingle &&
          char == '\'' &&
          next == '\'' &&
          next2 == '\'') {
        inTripleSingle = false;
        buffer.write(next);
        buffer.write(next2);
        i += 2;
      } else if (inTripleDouble && char == '"' && next == '"' && next2 == '"') {
        inTripleDouble = false;
        buffer.write(next);
        buffer.write(next2);
        i += 2;
      }
      i++;
      continue;
    }

    // Detect start of block comment
    if (char == '/' && next == '*') {
      inBlockComment = true;
      i += 2;
      continue;
    }

    // Detect start of single-line comment
    if (char == '/' && next == '/') {
      inSingleLineComment = true;
      i += 2;
      continue;
    }

    // Detect strings (including triple quotes)
    if (char == '\'') {
      if (next == '\'' && next2 == '\'') {
        inTripleSingle = true;
        buffer.write(char);
        buffer.write(next);
        buffer.write(next2);
        i += 3;
        continue;
      } else {
        inSingleQuote = true;
        buffer.write(char);
        i++;
        continue;
      }
    }
    if (char == '"') {
      if (next == '"' && next2 == '"') {
        inTripleDouble = true;
        buffer.write(char);
        buffer.write(next);
        buffer.write(next2);
        i += 3;
        continue;
      } else {
        inDoubleQuote = true;
        buffer.write(char);
        i++;
        continue;
      }
    }

    // Default: copy char
    buffer.write(char);
    i++;
  }

  return buffer.toString();
}
