#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

# --- Professional Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

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

# --- Helper: Get Milliseconds ---
get_time_ms() {
    if [ "$OS" = "Darwin" ]; then
        # macOS date doesn't support %N, use perl if available
        if command -v perl >/dev/null 2>&1; then
            perl -MTime::HiRes=time -e 'printf "%.0f\n", time()*1000'
        else
            # fallback to seconds if perl is missing
            echo $(($(date +%s) * 1000))
        fi
    else
        # GNU date supports %N, but sanitize in case it is unavailable.
        date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000))
    fi
}

# --- Helper: Performance Run ---
run_and_time() {
    local file=$1
    local asm=".build/tmp_out.s"
    local bin=".build/tmp_out"
    
    if [ -z "$file" ]; then
        echo -e "${RED}❌ No file specified!${NC}"
        return 1
    fi

    echo -e "${CYAN}🚀 Compiling $file...${NC}"
    
    # Compile
    ./snc "$file" > "$asm"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Compilation failed!${NC}"
        return 1
    fi

    # Link
    if [ "$OS" == "Darwin" ]; then
        $COMPILER -isysroot "$SDK_PATH" "$asm" -o "$bin"
    else
        $COMPILER "$asm" -o "$bin"
    fi

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Linking failed!${NC}"
        return 1
    fi

    echo -e "${CYAN}🏃 Running...${NC}"
    echo -e "${YELLOW}--------------------------------${NC}"
    
    # Accurate timing
    start_time=$(get_time_ms)
    "./$bin"
    exit_code=$?
    end_time=$(get_time_ms)
    start_time=${start_time//[^0-9]/}
    end_time=${end_time//[^0-9]/}
    if [ -z "$start_time" ]; then
        start_time=$(($(date +%s) * 1000))
    fi
    if [ -z "$end_time" ]; then
        end_time=$(($(date +%s) * 1000))
    fi
    
    echo -e "${YELLOW}--------------------------------${NC}"
    
    duration=$((end_time - start_time))
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✅ Done in ${BOLD}${duration}ms${NC}"
    else
        echo -e "${RED}⚠️  Crashed with code $exit_code (after ${duration}ms)${NC}"
    fi
}

# --- Helper: Watch Mode ---
watch_file() {
    local file=$1
    echo -e "${BOLD}${BLUE}👀 WATCH MODE ENABLED: $file${NC}"
    echo -e "${CYAN}Watching for changes... (Press Ctrl+C to stop)${NC}"
    
    # Initial run
    run_and_time "$file"
    
    # Get initial mod time (OS specific)
    if [ "$OS" == "Darwin" ]; then
        last_mod=$(stat -f "%m" "$file")
    else
        last_mod=$(stat -c "%Y" "$file")
    fi

    while true; do
        sleep 0.5
        if [ "$OS" == "Darwin" ]; then
            current_mod=$(stat -f "%m" "$file")
        else
            current_mod=$(stat -c "%Y" "$file")
        fi

        if [ "$current_mod" != "$last_mod" ]; then
            echo -e "\n${BOLD}${YELLOW}🔄 Change detected! Re-running...${NC}"
            run_and_time "$file"
            last_mod=$current_mod
        fi
    done
}

# --- The "@" Feature: Interactive Selector ---
if [ "$1" = "@" ]; then
    clear
    echo -e "${BOLD}${CYAN}🔍 DASH DEVICE DISCOVERY${NC}"
    echo -e "${BLUE}--------------------------${NC}"
    echo -e "${BOLD}📱 Platform:${NC}  $PLATFORM"
    echo -e "${BOLD}🏗️  Arch:${NC}      $ARCH"
    echo -e "${BOLD}🛠️  Compiler:${NC}  $COMPILER"
    echo -e "${BLUE}--------------------------${NC}"
    echo ""
    
    ALL_FILES_STR=$(find . -maxdepth 2 -name "*.sn" | sort)
    IFS=$'\n' read -rd '' -a ALL_FILES_ARR <<< "$ALL_FILES_STR"
    NUM_ALL_FILES=${#ALL_FILES_ARR[@]}
    
    SEARCH_QUERY=""
    PAGE_SIZE=12
    START_INDEX=0

    while true; do
        if [ -z "$SEARCH_QUERY" ]; then
            CURRENT_FILES_STR="$ALL_FILES_STR"
        else
            CURRENT_FILES_STR=$(echo "$ALL_FILES_STR" | grep -i "$SEARCH_QUERY")
        fi

        IFS=$'\n' read -rd '' -a CURRENT_FILES <<< "$CURRENT_FILES_STR"
        NUM_FILES=${#CURRENT_FILES[@]}
        
        VISIBLE_COUNT=$((NUM_FILES - START_INDEX))
        [ $VISIBLE_COUNT -gt $PAGE_SIZE ] && VISIBLE_COUNT=$PAGE_SIZE
        END_VAL=$((START_INDEX + VISIBLE_COUNT))
        
        echo -e "${BOLD}${BLUE}📂 SNlang Files ($((START_INDEX+1))-$END_VAL of $NUM_FILES):${NC}"
        [ ! -z "$SEARCH_QUERY" ] && echo -e "${YELLOW}🔎 Filtering for: '$SEARCH_QUERY'${NC}"
        
        for ((i=START_INDEX; i<END_VAL; i++)); do
            RELATIVE_INDEX=$((i - START_INDEX + 1))
            FILE_PATH="${CURRENT_FILES[$i]}"
            # Find original index
            ORIG_INDEX=-1
            for j in "${!ALL_FILES_ARR[@]}"; do
                if [[ "${ALL_FILES_ARR[$j]}" == "$FILE_PATH" ]]; then
                    ORIG_INDEX=$((j+1)); break;
                fi
            done
            printf "  ${CYAN}%2d)${NC} [${YELLOW}%3d${NC}] %s\n" "$RELATIVE_INDEX" "$ORIG_INDEX" "$FILE_PATH"
        done

        echo ""
        echo -e "${BOLD}COMMANDS:${NC}"
        echo -e "  ${GREEN}[#]${NC} Run once  |  ${GREEN}[w#]${NC} Watch mode  |  ${GREEN}[n]${NC} Next  |  ${GREEN}[s]${NC} Search  |  ${GREEN}[cq]${NC} Clear/Quit"
        read -p "👉 Selection: " INPUT

        if [[ "$INPUT" == "q" ]]; then exit 0; fi
        if [[ "$INPUT" == "cq" ]]; then clear; exit 0; fi
        if [[ "$INPUT" == "n" ]]; then
            START_INDEX=$((START_INDEX + PAGE_SIZE))
            [ $START_INDEX -ge $NUM_FILES ] && START_INDEX=0
            echo -e "${BLUE}---${NC}"
            continue
        fi
        if [[ "$INPUT" == "s" ]]; then
            read -p "🔍 Search: " SEARCH_QUERY
            START_INDEX=0; continue
        fi

        # Selection Logic
        MODE="run"
        SEL_INPUT="$INPUT"
        FILE=""
        if [[ "$INPUT" == w* ]]; then
            MODE="watch"
            SEL_INPUT="${INPUT#w}"
        fi

        if [[ "$SEL_INPUT" =~ ^[0-9]+$ ]]; then
            # Relative
            if [ "$SEL_INPUT" -ge 1 ] && [ "$SEL_INPUT" -le "$VISIBLE_COUNT" ]; then
                FILE="${CURRENT_FILES[$((START_INDEX + SEL_INPUT - 1))]}"
            # Global
            elif [ "$SEL_INPUT" -ge 1 ] && [ "$SEL_INPUT" -le "$NUM_ALL_FILES" ]; then
                FILE="${ALL_FILES_ARR[$((SEL_INPUT-1))]}"
            fi

            if [ ! -z "$FILE" ]; then
                if [ "$MODE" == "watch" ]; then
                    watch_file "$FILE"
                else
                    run_and_time "$FILE"
                    echo ""
                    read -p "Press Enter to return to menu..."
                    clear
                    continue
                fi
            fi
        fi
        echo -e "${RED}❌ Invalid selection.${NC}"
    done
elif [ -n "$1" ]; then
    # Standard CLI run
    run_and_time "$1"
else
    echo -e "${BOLD}${CYAN}🚀 SNlang Dash Tool${NC}"
    echo -e "Usage:"
    echo -e "  ./run.sh <file.sn>    Compile and run a specific file"
    echo -e "  ./run.sh @            Open the interactive file selector"
    echo ""
fi
