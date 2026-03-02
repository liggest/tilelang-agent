---
name: tilelang-debug-helper
description: How to add debugging capabilities to TileLang Ascend example operators. Use this skill whenever the user asks to debug a TileLang example, add GDB debugging code, create a debug version of an example, or mentions GDB, debugging, breakpoints, or VSCode debugging in the context of TileLang operators.
---

# TileLang Debug Helper

This skill helps you add debugging capabilities to TileLang Ascend example operators so they can be debugged with GDB in VSCode.

## Understanding the Task

When a user wants to debug a TileLang example, they need to:
1. Add code to print the process ID (PID)
2. Add code to wait for GDB attachment
3. This allows attaching a GDB debugger to the running Python process

## When to Use This Skill

Use this skill when:
- User asks to "debug" or "add debugging code" to a TileLang example
- User mentions GDB, breakpoints, or VSCode debugging
- User wants to step through C++ code in a TileLang operator
- User needs to inspect variables or execution flow in a TileLang kernel

## How to Add Debugging Code

### Step 1: Read the Original Example

First, read the example file that needs debugging. These are typically located in the `examples/` directory and end with `.py`.

### Step 2: Identify the Right Location

Find the best place to insert the debugging code. Look for:
- After imports and before the main test execution
- Before the function is called with `@tilelang.jit`
- After `torch.manual_seed()` if present
- Before the test loop starts

The goal is to pause execution before the actual kernel runs, so GDB can be attached.

### Step 3: Add Debug Code

Insert the following code at the identified location:

```python
import os

# Debug: Print PID and wait for GDB attachment
print(f"PID: {os.getpid()}")
input("Press Enter after attaching GDB...")
```

**Important:**
- Make sure `import os` is at the top of the file (or add it if not present)
- Place this code BEFORE the kernel execution, not inside the kernel function
- The `input()` call will pause execution, giving time to attach GDB

### Step 4: Save the Debug Version

Save the modified file. Common naming conventions:
- Add `_debug` suffix: `sigmoid_debug.py`
- Or keep the original name if replacing it

## Complete Example

Here's how a debug version should look:

```python
import os
import tilelang
import tilelang.language as T
import torch

tilelang.cache.clear_cache()

@tilelang.jit(out_idx=[1])
def sigmoid(M, N, block_M, block_N, dtype="float"):
    # ... kernel implementation ...
    pass

torch.manual_seed(0)

# Debug: Print PID and wait for GDB attachment
print(f"PID: {os.getpid()}")
input("Press Enter after attaching GDB...")

# Test execution
test_configs = [(256, 256, 64, 64)]
for M, N, block_M, block_N in test_configs:
    func = sigmoid(M, N, block_M, block_N)
    a = torch.randn(M, N).npu()
    b = func(a)
    # ... assertions ...
```

## Additional Context

### What Happens After Adding Debug Code

1. User runs the Python script
2. Script prints PID and pauses
3. User attaches GDB to that PID in VSCode
4. User presses Enter in the Python console
5. Execution continues and GDB can hit breakpoints in C++ code

### Prerequisites

The user should also:
- Have modified `CMakeLists.txt` to compile with `-g -O0` for debug symbols
- Have VSCode configured with GDB debug tasks
- Have the TileLang project compiled with debug information

If the user hasn't done these, mention them as next steps after adding the debug code.

## Common Patterns

### Pattern 1: Simple Example with Single Test

For examples with a simple structure:
- Add debug code after imports and setup
- Before the function call

### Pattern 2: Multiple Test Configurations

For examples with multiple test cases:
- Add debug code before the test loop
- This allows debugging any of the test cases

### Pattern 3: Examples with Multiple Functions

For examples with multiple kernel functions:
- Add debug code before the first function call
- User can set breakpoints in specific functions

## Verification

After adding the debug code:
1. Verify the file is syntactically correct
2. Confirm `import os` is present
3. Confirm the debug code is placed before kernel execution
4. The file should run and pause at the `input()` call

## Output

Always provide:
- The path to the created/modified debug file
- Brief instructions on how to use it (run, attach GDB, continue)
- Mention any additional setup needed if not already done
