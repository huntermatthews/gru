# Justfile for GRU
set quiet := true
set shell := ["fish", "-c"]

[private]
default:
    just --list

# Build the GRU script
build:
    #! /usr/bin/env fish
    echo "Building GRU..."
    echo "#!/usr/bin/env fish" > gru
    # This order is IMPORTANT - debug, errors, dict, then anything else, gru(main) last
    for f in \
        debug.fish \
        boolean.fish \
        errors.fish \
        dict.fish \
        conversions.fish \
        inputs.fish \
        readers.fish \
        outputs.fish \
        collector.fish \
        requires.fish \
        os.fish \
        gru.fish
        cat $f >> gru
    end
    chmod +x gru

# Remove build artifacts
clean:
    echo "Cleaning up..."
    rm -f gru
