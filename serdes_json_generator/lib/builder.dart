import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

Builder jsonBuilder(BuilderOptions options) =>
    SharedPartBuilder([SerdesJsonGenerator()], 'multiply');
