# Mac Test Steps

Run these commands in Terminal on the Mac.

## 1. Go to the repo

```bash
cd /path/to/snc
```

Replace `/path/to/snc` with the actual repo path on the Mac.

## 2. Run the main test flow

```bash
make test
```

This should:

- build `snc`
- compile the example `.sn` programs
- assemble/link them with `clang`
- run them

## 3. If `make test` fails, collect environment info

Run:

```bash
clang --version
make
```

Send the full output back.

## 4. Test the newer feature cases one by one

### Nullable list direct declaration

```bash
./snc examples/nullable_list_direct.sn > /tmp/nullable_list_direct.s
clang /tmp/nullable_list_direct.s -o /tmp/nullable_list_direct
/tmp/nullable_list_direct
```

### Nullable decimal flow

```bash
./snc examples/nullable_decimal.sn > /tmp/nullable_decimal.s
clang /tmp/nullable_decimal.s -o /tmp/nullable_decimal
/tmp/nullable_decimal
```

### Default parameters

```bash
./snc examples/default_params.sn > /tmp/default_params.s
clang /tmp/default_params.s -o /tmp/default_params
/tmp/default_params
```

## 5. If anything breaks

Send back:

- the exact command that failed
- the full terminal output
- whether the failure happened during `make`, `snc`, `clang`, or program execution

## 6. If everything passes

Then commit and push:

```bash
git status
git add .
git commit -m "Fix nullable declarations and tighten default parameter handling"
git push origin main
```
