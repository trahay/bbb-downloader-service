# bbb-downloader service

Automate the download of BBB presentations. Just run the script `enqueue_download.sh`, and the presentation will be downloaded.

## installing dependencies

```
sudo apt install inotify-tools task-spooler
```

## Configuration

Rename `config.sh.template` into `config.sh` and edit the configuration variables:

- `BBB_DOWNLOADER_ROOT`: path to capture-full-replay.sh
- `INPUT_DIR`: directory where requests are enqueued (by default: `to_be_downloaded`)
- `OUTPUT_DIR`: directory where presentations are stored once downloaded (by default: `downloads`)


## Enabling the service
Run `watchdog.sh`. This script waits for new files in `INPUT_DIR` and process them upon creation.


## Downloading a presentation

Copy a `request.json` file into the input directory. The request file contains the URL of the presentation as well as options to be passed to `bbb-downloader`. An example of .json file is given:


```
{
    "url": "https://bbb-node.imtbs-tsp.eu/playback/presentation/2.0/playback.html?meetingId=fb8a9cb664e003d61d06e6c7f71196fb9b2c0922-1588666735451",
    "main_only": "yes",
    "output_file": "plop.mp4",
    "startup_duration": "10",
    "stop_duration": "15",
    "dont_crop": "y",
    "save_files": "y"
}
```

The watchdog will detect this new file, and enqueue a task in charge of downloading the presentation.