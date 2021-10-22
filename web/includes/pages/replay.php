<?php

/**
 * This page handles contents of a replayYYYYMMDD_HHMMSS(replay) directory.
 * note: $replay variable is set in 'body.php'
 * 
 * Goal of this logic:
 *  Pass map data structure as a json object to javascript.
 *  map type: { string => []string }. In this case it is
 *  { file_name => file_content }
 * 
 * Logic: 
 *  1. read every file in replay directory (except those we dont need)
 *  2. map file_name to file_content
 *  3. pass this map to javascript
 */


include BASE_DIR . '/includes/components/navbar.php';

# first check if directory exist
$replay_path = BASE_DIR . 'rpctest_results/' . $replay;

if (!is_dir($replay_path)) : ?>
    <div class="section">
        <h3>Error: There is no test results for <?php echo $replay ?></h3>
    </div>


<?php else :

    # take YYYYMMDD and HHMMSS out of 'replayYYYYMMDD_HHMMSS'
    # and make a Unix timestamp out of it, so we can format it 
    # however we want
    $rx_date_time = '/^replay(\d{8})\_(\d{6})\/?$/';
    preg_match($rx_date_time, $replay, $matches);
    assert(count($matches) >= 3);
    $timestamp = strtotime(implode(" ", array_slice($matches, 1))); 

    # open erigon_branch.txt to get branch name, so we can display
    # what branch was tested
    $erigon_branch = $replay_path . '/erigon_branch.txt';
    $f = fopen($erigon_branch, 'r');
    $branch = fgets($f);
    fclose($f) ?>

    <div class="section">
        <div id="replay-info">
            <p><span><strong>Replay: </strong><?php $date = new DateTime();
                                                $date->setTimestamp($timestamp);
                                                echo $date->format('Y-m-d H:i:s') ?> </span></p>
            <p><span><strong>Branch: </strong><?php echo $branch ?></span></p>
        </div>
    </div>

    <nav id="dynamic-tabs-nav">

        <ul id="dynamic-tabs">

            <?php
            $pseudo_links = [];

            # go over each file in replay directory
            foreach (new DirectoryIterator($replay_path) as $fileInfo) {
                $file_name = $fileInfo->getFilename();

                if (
                    !$fileInfo->isDot() &&
                    $file_name !== 'erigon_branch.txt' &&
                    substr($file_name, 0, 1) !== "_" 
                    # we dont need files starting with "_" (they are helper files)
                ) { 

                    $file = $replay_path . '/' . $file_name; 
                    $f = fopen($file, 'r');
                    $contents = [];
                    if ($f) {
                        while (($line = fgets($f)) !== false) {
                            array_push($contents, $line);
                        }
                    }

                    fclose($f);
                    $pseudo_links[$file_name] = $contents;
                }
            }

            ?>
        </ul>

    </nav>

    <div id="dynamic-content" class="section"></div>

    <script src="/static/js/dynamic_links.js"></script>

    <script>
        let map = <?php echo json_encode($pseudo_links) ?>;
        handle_files_content(map);
    </script>

<?php endif ?>