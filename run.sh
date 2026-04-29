#!/bin/bash

# --- Device Detection Logic ---
OS=$(uname -s)
ARCH=$(uname -m)
COMPILER=$(which clang || which gcc)
SDK_PATH=""

if [ "$OS" == "Darwin" ]; then
    PLATFORM="macOS"
    SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)
elif [ "$OS" == "Linux" ]; then
    PLATFORM="Linux"
else
    PLATFORM="Unknown ($OS)"
fi

# --- The "@" Feature: Device Discovery & Interactive Selector ---
if [ "$1" == "@" ]; then
    echo "🔍 SNlang Device Discovery"
    echo "--------------------------"
    echo "📱 Platform:  $PLATFORM"
    echo "🏗️  Arch:      $ARCH"
    echo "🛠️  Compiler:  $COMPILER"
    echo "--------------------------"
    echo ""
    
    # Pre-load files into a flat list for speed
    ALL_FILES_STR=$(find . -maxdepth 2 -name "*.sn" | sort)
    IFS=$'\n' read -rd '' -a ALL_FILES_ARR <<< "$ALL_FILES_STR"
    NUM_ALL_FILES=${#ALL_FILES_ARR[@]}
    
    if [ $NUM_ALL_FILES -eq 0 ]; then
        echo "❌ No .sn files found."
        exit 1
    fi

    # Search and Pagination State
    SEARCH_QUERY=""
    PAGE_SIZE=15
    START_INDEX=0

    while true; do
        # Filter files based on search query
        if [ -z "$SEARCH_QUERY" ]; then
            CURRENT_FILES_STR="$ALL_FILES_STR"
        else
            CURRENT_FILES_STR=$(echo "$ALL_FILES_STR" | grep -i "$SEARCH_QUERY")
        fi

        IFS=$'\n' read -rd '' -a CURRENT_FILES <<< "$CURRENT_FILES_STR"
        NUM_FILES=${#CURRENT_FILES[@]}
        
        if [ ! -z "$SEARCH_QUERY" ]; then
            echo "🔎 Searching for: '$SEARCH_QUERY' ($NUM_FILES results)"
        fi
        
        VISIBLE_COUNT=$((NUM_FILES - START_INDEX))
        [ $VISIBLE_COUNT -gt $PAGE_SIZE ] && VISIBLE_COUNT=$PAGE_SIZE
        END_VAL=$((START_INDEX + VISIBLE_COUNT))
        
        echo "📂 Available SNlang Files (Showing $((START_INDEX+1)) to $END_VAL of $NUM_FILES):"
        
        # Display current batch
        for ((i=START_INDEX; i<END_VAL; i++)); do
            RELATIVE_INDEX=$((i - START_INDEX + 1))
            FILE_PATH="${CURRENT_FILES[$i]}"
            
            # Find original index
            ORIG_INDEX=-1
            for j in "${!ALL_FILES_ARR[@]}"; do
                if [[ "${ALL_FILES_ARR[$j]}" == "$FILE_PATH" ]]; then
                    ORIG_INDEX=$((j+1))
                    break
                fi
            done
            
            printf "  %2d) [%3d] %s\n" "$RELATIVE_INDEX" "$ORIG_INDEX" "$FILE_PATH"
        done

        echo ""
        echo "Commands: [#] Run  |  [n] Next  |  [s] Search  |  [q] Quit  |  [cq] Clear & Quit"
        read -p "👉 Selection: " INPUT

        if [[ "$INPUT" == "q" ]]; then exit 0; fi
        
        if [[ "$INPUT" == "cq" ]]; then 
            clear
            exit 0
        fi

        if [[ "$INPUT" == "n" ]]; then
            START_INDEX=$((START_INDEX + PAGE_SIZE))
            [ $START_INDEX -ge $NUM_FILES ] && START_INDEX=0
            echo "--------------------------------"
            continue
        fi

        if [[ "$INPUT" == "s" ]]; then
            read -p "🔍 Enter search term (leave empty to clear): " SEARCH_QUERY
            START_INDEX=0
            echo "--------------------------------"
            continue
        fi

        # --- SELECTION LOGIC ---
        if [[ "$INPUT" =~ ^[0-9]+$ ]]; then
            # 1. Relative
            if [ "$INPUT" -ge 1 ] && [ "$INPUT" -le "$VISIBLE_COUNT" ]; then
                ACTUAL_INDEX=$((START_INDEX + INPUT - 1))
                SELECTED_FILE="${CURRENT_FILES[$ACTUAL_INDEX]}"
                echo "✅ Selected: $SELECTED_FILE"
                set -- "$SELECTED_FILE"
                break
            # 2. Global
            elif [ "$INPUT" -ge 1 ] && [ "$INPUT" -le "$NUM_ALL_FILES" ]; then
                SELECTED_FILE="${ALL_FILES_ARR[$((INPUT-1))]}"
                echo "✅ Selected Global ID $INPUT: $SELECTED_FILE"
                set -- "$SELECTED_FILE"
                break
            fi
        fi
        
        echo "❌ Invalid selection."
    done
fi

# --- Standard Run Logic ---
if [ -z "$1" ]; then
    echo "Usage: ./run.sh <filename.sn>  (or use './run.sh @' for interactive mode)"
    exit 1
fi

SOURCE_FILE=$1
ASM_FILE=".build/tmp_out.s"
BINARY_FILE=".build/tmp_out"

mkdir -p .build

echo "🚀 Compiling $SOURCE_FILE for $PLATFORM ($ARCH)..."

# 1. Compile SNlang to Assembly
./snc "$SOURCE_FILE" > "$ASM_FILE"
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

# 2. Assemble and Link
echo "🔗 Linking with $COMPILER..."
if [ "$OS" == "Darwin" ]; then
    $COMPILER -isysroot "$SDK_PATH" "$ASM_FILE" -o "$BINARY_FILE"
else
    $COMPILER "$ASM_FILE" -o "$BINARY_FILE"
fi

if [ $? -ne 0 ]; then
    echo "❌ Linking failed!"
    exit 1
fi

# 3. Run the binary
echo "🏃 Running program..."
echo "--------------------------------"
"./$BINARY_FILE"
echo "--------------------------------"
echo "✅ Done."
