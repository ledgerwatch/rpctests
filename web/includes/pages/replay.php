<?php

include BASE_DIR . '/includes/components/navbar.php';

# first check if directory exist
$replay_path = BASE_DIR . 'rpctest_results/' . $replay;

$rx_date_time = '/^replay(\d{8})\_(\d{6})\/?$/';
preg_match($rx_date_time, $replay, $matches);
assert(count($matches) >= 3);
$timestamp = strtotime(implode(" ", array_slice($matches, 1)));

if (!is_dir($replay_path)) : ?>
    <div class="section">
        <h3>Error: There is no test results for <?php echo $replay ?></h3>
    </div>


<?php else :


    # 1. open erigon_branch.txt to get branch name
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

            foreach (new DirectoryIterator($replay_path) as $fileInfo) {
                $file_name = $fileInfo->getFilename();
                if (
                    !$fileInfo->isDot() &&
                    $file_name !== 'erigon_branch.txt'
                ) {

                    $file = $replay_path . '/' . $file_name;
                    $f = fopen($file, 'r');

                    $linecount = 0;
                    if ($f) {
                        while (($line = fgets($f)) !== false) {
                            $linecount++;
                        }
                    }

                    fclose($f);


                    $spl_file = new SplFileObject($file);
                    $contents = [];

                    $max_lines = 100; // read last 100 lines only
                    $start_line =
                        $linecount > $max_lines ?
                        $linecount - $max_lines : 0;
                    // echo $file, $linecount,  $start_line . "\n";
                    for ($i = $start_line; $i < $linecount; $i++) {
                        $spl_file->seek($i);
                        array_push($contents, $spl_file->current() . "\n");
                    }

                    $pseudo_links[$file_name] = $contents;
                }
            }

            ?>
        </ul>

    </nav>

    <div id="dynamic-content" class="section">

    </div>

    <script src="/static/js/dynamic_links.js"></script>

    <script>
        let map = <?php echo json_encode($pseudo_links) ?>;
        handle_files_content(map);
    </script>

<?php endif ?>