function djmgmt
    set subcommand $argv[1]
    set -e argv[1]

    switch $subcommand
        case info
            set detail $argv[1]

            echo "djmgmt — DJ management toolkit"
            echo ""
            echo "Package:   ~/developer/djmgmt  (pip, Python 3.13)"
            echo "Frontend:  Streamlit            http://localhost:8501"
            echo "           (auto-started via LaunchAgent: zachvp.djmgmt.wake)"

            if contains -- $detail pipeline all
                echo ""
                echo "Pipeline:  downloads → encode (AIFF/MP3) → organize by date → Rekordbox XML → rsync → Navidrome"
                echo "Server:    corevega.local:12000 (rsync daemon, Navidrome media server)"
            end

            if contains -- $detail modules all
                echo ""
                echo "Key modules:"
                echo "  music.py     end-to-end batch processing (process, update_library, record_collection)"
                echo "  encode.py    ffmpeg transcoding — lossless→AIFF, lossy→320k MP3"
                echo "  sync.py      rsync to Navidrome + trigger scan"
                echo "  library.py   Rekordbox XML collection management"
                echo "  tags.py      ID3/FLAC metadata (mutagen)"
                echo "  playlist.py  DJ mix/TSV playlist management"
            end

        case exec
            python -m djmgmt $argv
        case '*'
            echo "usage: djmgmt <subcommand>"
            echo ""
            echo "subcommands:"
            echo "  info [pipeline|modules|all]  show project overview (default: package + frontend only)"
            echo "  exec                         run the djmgmt Python module (pass args through)"
    end
end
