import 'dart:cli';
import 'dart:collection';
import 'dart:io';
import 'dart:convert';

enum Variable { x, y, z, w }

class AluState {
  int x, y, z, w;

  AluState(this.x, this.y, this.z, this.w);

  AluState.initial() : this(0, 0, 0, 0);

  AluState.from(AluState state) : this(state.x, state.y, state.z, state.w);
}

abstract class Input {
  int getValue(AluState aluState);
}

class NumericInput implements Input {
  final int literal;

  NumericInput(this.literal);

  @override
  int getValue(_) => this.literal;
}

class VariableInput implements Input {
  final Variable variable;

  VariableInput(this.variable);

  @override
  int getValue(aluState) {
    switch (this.variable) {
      case Variable.x:
        return aluState.x;
      case Variable.y:
        return aluState.y;
      case Variable.z:
        return aluState.z;
      case Variable.w:
        return aluState.w;
    }
  }
}

abstract class Output {
  void setValue(int value, AluState aluState);
}

class VariableOutput implements Output {
  final Variable variable;

  VariableOutput(this.variable);

  @override
  void setValue(int value, aluState) {
    switch (variable) {
      case Variable.x:
        aluState.x = value;
        break;
      case Variable.y:
        aluState.y = value;
        break;
      case Variable.z:
        aluState.z = value;
        break;
      case Variable.w:
        aluState.w = value;
        break;
    }
  }
}

class InOut {
  final Input input;
  final Output output;

  InOut(this.input, this.output);
}

abstract class Instruction {
  void execute(AluState aluState);

  bool canExecute(AluState aluState);
}

class InpInstruction implements Instruction {
  final Output output;

  InpInstruction(this.output);

  @override
  void execute(aluState) {
    throw Exception("Invalid operation");
  }

  @override
  bool canExecute(_) => throw Exception("Invalid operation");

  void assumeInput(int assumedInput, AluState aluState) {
    output.setValue(assumedInput, aluState);
  }
}

class AddInstruction implements Instruction {
  final InOut inout1;
  final Input input2;

  AddInstruction(this.inout1, this.input2);

  @override
  void execute(aluState) {
    inout1.output.setValue(
        inout1.input.getValue(aluState) + input2.getValue(aluState), aluState);
  }

  @override
  bool canExecute(_) => true;
}

class MulInstruction implements Instruction {
  final InOut inout1;
  final Input input2;

  MulInstruction(this.inout1, this.input2);

  @override
  void execute(aluState) {
    inout1.output.setValue(
        inout1.input.getValue(aluState) * input2.getValue(aluState), aluState);
  }

  @override
  bool canExecute(_) => true;
}

class DivInstruction implements Instruction {
  final InOut inout1;
  final Input input2;

  DivInstruction(this.inout1, this.input2);

  @override
  void execute(aluState) {
    inout1.output.setValue(
        (inout1.input.getValue(aluState).toDouble() /
                input2.getValue(aluState).toDouble())
            .floor(),
        aluState);
  }

  @override
  bool canExecute(aluState) => input2.getValue(aluState) != 0;
}

class ModInstruction implements Instruction {
  final InOut inout1;
  final Input input2;

  ModInstruction(this.inout1, this.input2);

  @override
  void execute(aluState) {
    inout1.output.setValue(
        (inout1.input.getValue(aluState).toDouble() %
                input2.getValue(aluState).toDouble())
            .floor(),
        aluState);
  }

  @override
  bool canExecute(aluState) =>
      !(inout1.input.getValue(aluState) < 0 || input2.getValue(aluState) <= 0);
}

class EqlInstruction implements Instruction {
  final InOut inout1;
  final Input input2;

  EqlInstruction(this.inout1, this.input2);

  @override
  void execute(aluState) {
    inout1.output.setValue(
        inout1.input.getValue(aluState) == input2.getValue(aluState) ? 1 : 0,
        aluState);
  }

  @override
  bool canExecute(_) => true;
}

class FileParser {
  Input parseInput(String param) {
    switch (param) {
      case "x":
        return new VariableInput(Variable.x);
      case "y":
        return new VariableInput(Variable.y);
      case "z":
        return new VariableInput(Variable.z);
      case "w":
        return new VariableInput(Variable.w);
      default:
        var parsed = int.tryParse(param);
        if (parsed != null) {
          return new NumericInput(parsed);
        }
        throw Exception(
            "Compile ERROR: expected input, but was not able to parse: ${param}");
    }
  }

  Output parseOutput(String param) {
    switch (param) {
      case "x":
        return new VariableOutput(Variable.x);
      case "y":
        return new VariableOutput(Variable.y);
      case "z":
        return new VariableOutput(Variable.z);
      case "w":
        return new VariableOutput(Variable.w);
      default:
        throw Exception(
            "Compile ERROR: expected output, but was not a legal variable: ${param}");
    }
  }

  InOut parseInout(String param) {
    switch (param) {
      case "x":
        return new InOut(
            new VariableInput(Variable.x), new VariableOutput(Variable.x));
      case "y":
        return new InOut(
            new VariableInput(Variable.y), new VariableOutput(Variable.y));
      case "z":
        return new InOut(
            new VariableInput(Variable.z), new VariableOutput(Variable.z));
      case "w":
        return new InOut(
            new VariableInput(Variable.w), new VariableOutput(Variable.w));
      default:
        throw Exception(
            "Compile ERROR: expected In/Out, but was not a legal variable: ${param}");
    }
  }

  List<Instruction> compileFile(String path) {
    var instructions = new File(path)
        .openRead()
        .map(utf8.decode)
        .transform(new LineSplitter())
        .map((l) {
      var arr = l.split(' ');
      switch (arr[0]) {
        case 'inp':
          return new InpInstruction(parseOutput(arr[1]));
        case 'add':
          return new AddInstruction(parseInout(arr[1]), parseInput(arr[2]));
        case 'mul':
          return new MulInstruction(parseInout(arr[1]), parseInput(arr[2]));
        case 'div':
          return new DivInstruction(parseInout(arr[1]), parseInput(arr[2]));
        case 'mod':
          return new ModInstruction(parseInout(arr[1]), parseInput(arr[2]));
        case 'eql':
          return new EqlInstruction(parseInout(arr[1]), parseInput(arr[2]));
      }
      return new AddInstruction(
          new InOut(
              new VariableInput(Variable.x), new VariableOutput(Variable.x)),
          new VariableInput(Variable.y));
    });

    return waitFor(instructions.toList());
  }
}

class ExecutionResult {
  final bool isFinished;
  final bool isSuccessful;
  final bool isFailed;

  final int instructionPointer;

  ExecutionResult(this.isFinished, this.isSuccessful, this.isFailed,
      this.instructionPointer);
}

class Executor {
  ExecutionResult executeUntilInputInstruction(
      List<Instruction> instructions, int instructionPointer, AluState state) {
    final length = instructions.length;

    while (true) {
      if (instructionPointer >= length) {
        // Program finished
        return new ExecutionResult(true, true, false, instructionPointer);
      }

      var instructionToExecute = instructions[instructionPointer];

      if (instructionToExecute is InpInstruction) {
        return new ExecutionResult(false, true, false, instructionPointer);
      }

      if (!instructionToExecute.canExecute(state)) {
        // invalid operation
        return new ExecutionResult(false, false, true, instructionPointer);
      }

      instructionToExecute.execute(state);

      instructionPointer++;
    }
  }
}

class Interrupt {
  final List<int> usedInputs;

  final AluState aluState;

  Interrupt(this.usedInputs, this.aluState);
}

abstract class SolutionPicker {
  bool shouldTakeSolution(List<int> list1, List<int> list2);
}

class SolutionPickerPart1 implements SolutionPicker {
  bool shouldTakeSolution(List<int> list1, List<int> list2) {
    for (int i = 0; i < list1.length; i++) {
      final thisItem = list1[i];
      final otherItem = list2[i];

      if (thisItem > otherItem) {
        return true;
      }
      if (thisItem < otherItem) {
        return false;
      }
    }
    assert(false);
    return false;
  }
}

class SolutionPickerPart2 implements SolutionPicker {
  bool shouldTakeSolution(List<int> list1, List<int> list2) {
    for (int i = 0; i < list1.length; i++) {
      final thisItem = list1[i];
      final otherItem = list2[i];

      if (thisItem > otherItem) {
        return false;
      }
      if (thisItem < otherItem) {
        return true;
      }
    }
    assert(false);
    return false;
  }
}

class PartialExecutionResult {
  final List<Interrupt> interrupts;
  final int instructionPointer;

  PartialExecutionResult(this.interrupts, this.instructionPointer);
}

class ValidSequenceNumberFinder {
  PartialExecutionResult ExecutePart(
      List<Interrupt> sequences,
      Executor executor,
      List<Instruction> instructions,
      SolutionPicker checker,
      int instructionPointer) {
    HashMap<int, Interrupt> calculatedSequences = new HashMap();

    final inputInstruction = instructions[instructionPointer];
    int endInstructionPointer = -1;

    sequences.forEach((sequence) {
      for (int w = 1; w < 10; w++) {
        final appliedInputs = sequence.usedInputs.toList();
        final initialAluState = AluState.from(sequence.aluState);
        if (inputInstruction is InpInstruction) {
          inputInstruction.assumeInput(w, initialAluState);
        } else {
          assert(false);
        }

        appliedInputs.add(w);

        final partExecutionResult = executor.executeUntilInputInstruction(
            instructions, instructionPointer + 1, initialAluState);
        endInstructionPointer = partExecutionResult.instructionPointer;

        if (calculatedSequences.containsKey(initialAluState.z)) {
          if (checker.shouldTakeSolution(appliedInputs,
              calculatedSequences[initialAluState.z]!.usedInputs)) {
            calculatedSequences[initialAluState.z] =
                new Interrupt(appliedInputs, initialAluState);
          }
        } else {
          calculatedSequences[initialAluState.z] =
              new Interrupt(appliedInputs, initialAluState);
        }
      }
    });

    final validNumber = calculatedSequences[0];
    if (validNumber != null && validNumber.usedInputs.length == 14) {
      print("Result = ${validNumber.usedInputs}");
    }

    return new PartialExecutionResult(
        calculatedSequences.values.toList(), endInstructionPointer);
  }
}

main() {
  final path = 'input.txt';
  final instructions = new FileParser().compileFile(path);

  final executor = new Executor();
  final sequenceFinder = new ValidSequenceNumberFinder();

  final solutionPickerPart1 = new SolutionPickerPart1();
  var solveResult = [new Interrupt([], AluState.initial())];
  var instructionPointer = 0;
  print("Part 1:");
  for (int i = 0; i < 14; i++) {
    final partialExecutionResult = sequenceFinder.ExecutePart(
        solveResult, executor, instructions, solutionPickerPart1, instructionPointer);
    solveResult = partialExecutionResult.interrupts;
    instructionPointer = partialExecutionResult.instructionPointer;
    print("#Variants = ${solveResult.length}");
  }

  final solutionPickerPart2 = new SolutionPickerPart2();
  solveResult = [new Interrupt([], AluState.initial())];
  instructionPointer = 0;
  print("Part 2:");
  for (int i = 0; i < 14; i++) {
    final partialExecutionResult = sequenceFinder.ExecutePart(
        solveResult, executor, instructions, solutionPickerPart2, instructionPointer);
    solveResult = partialExecutionResult.interrupts;
    instructionPointer = partialExecutionResult.instructionPointer;
    print("#Variants = ${solveResult.length}");
  }
}
