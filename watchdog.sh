#!/bin/bash

if [ ! -f config.sh ]; then
    echo "Please edit config.sh" >&2
    exit 1
fi

source config.sh

if [ ! -f "$BBB_DOWNLOADER_ROOT/capture-full-replay.sh" ];then
    echo "Cannot find $BBB_DOWNLOADER_ROOT/capture-full-replay.sh" >&2
    echo "Please edit BBB_DOWNLOADER_ROOT in config.sh" >&2
    exit 1
fi

if ! mkdir -p $INPUT_DIR 2>/dev/null ; then
    echo "Cannot create $INPUT_DIR" >&2
    exit 1
fi
if ! mkdir -p $OUTPUT_DIR 2>/dev/null ; then
    echo "Cannot create $OUTPUT_DIR" >&2
    exit 1
fi

CAPTURE=$(realpath "$BBB_DOWNLOADER_ROOT/capture-full-replay.sh")


function getvalue() {
    input_file=$1
    key=$2
    value=$(jq ".$key" "$input_file")
    if [ "$value" = "null" ]; then
	return;
    fi
    # remove quotes at the beginning/end of the string
    temp="${value%\"}"
    value="${temp#\"}"

    echo $value
}

if [ -n $MAX_CONCURRENT_TASKS ]; then  
    echo tsp -S $MAX_CONCURRENT_TASKS
    tsp -S $MAX_CONCURRENT_TASKS
    if [ $? -ne 0 ]; then
	echo "tsp -S $MAX_CONCURRENT_TASKS failed" >&2
	exit 1
    fi    
fi


inotifywait -m $INPUT_DIR -e create -e moved_to |
    while read dir action file; do
        echo "The file '$file' appeared in directory '$dir' via '$action'"

	input_file="$INPUT_DIR/$file"
	url=$(getvalue "$input_file" "url" )
	startup=$(getvalue "$input_file" "startup_duration")
	stop=$(getvalue "$input_file" "stop_duration")
	main=$(getvalue "$input_file" "main_only")
	crop=$(getvalue "$input_file" "dont_crop")
	output_file=$(getvalue "$input_file" "output_file")
	save=$(getvalue "$input_file" "save_files")

	tmp_dir=$(mktemp -d -p $OUTPUT_DIR)
        echo "Saving file '$file' into $tmp_dir"
	export TMPDIR=$(realpath $tmp_dir)
	mv $input_file $tmp_dir

	cd $tmp_dir
	cmd="bash $CAPTURE"
	if [ -n "$startup" ]; then
	    cmd="$cmd -s $startup"
	fi
	if [ -n "$stop" ]; then
	    cmd="$cmd -e $stop";
	fi
	if [ -n "$main" ]; then
	    cmd="$cmd -m";
	fi
	if [ -n "$crop" ]; then
	    cmd="$cmd -c"
	fi
	if [ -n "$output_file" ]; then
	    cmd="$cmd -o $output_file"
	fi
	if [ -n "$save" ]; then
	    cmd="$cmd -s";
	fi
	cmd="$cmd $url"

	echo tsp $cmd
	tsp $cmd
#	$cmd
	cd -

	#	mv "$INPUT_DIR/$file" $OUTPUT_DIR
        # do something with the file
    done
