<?php

include BASE_DIR . '/includes/components/navbar.php';

?>
<div class="section">

    <nav id="replays-links">
        <h3>Replays: </h3>
        <?php

        /**
         * This file generates "links"/buttons to navigate between rpctest results
         * 
         * Goal of this logic:
         *  displey "links"/buttons to every test result in decreasing order
         *  the latest test result first, the oldest last
         * 
         * Logic:
         *  1. go over each directory in rpctest result direcotry
         *  2. make a mapping: { timestamp => link_to_test_result }
         *      so we can sort it using timestamp
         *      timestamp represents a date the test run
         *  3. display every "link"/button
         */

        # regex to capture YYYYMMDD and HHMMSS
        $rx_date_time = '/^replay(\d{8})\_(\d{6})\/?$/';
        $to_sorted_dates = []; # map we will sort later

        /**
         * takes a link to directory and a directory name \
         * directory name example: 'replayYYYYMMDD_HHMMSS' \
         * forms mapping { timestamp => link } 
         */
        function make_mapping(string $link, string $replay_dir)
        {
            global $rx_date_time;
            global $to_sorted_dates;

            # take YYYYMMDD and HHMMSS out of 'replayYYYYMMDD_HHMMSS'
            # and make a Unix timestamp using it, so we can sort links
            preg_match($rx_date_time, $replay_dir, $matches);
            assert(count($matches) >= 3);
            $timestamp = strtotime(implode(" ", array_slice($matches, 1)));
            # create a mapping 'int' => 'string'
            $to_sorted_dates[$timestamp] = $link;
        }

        # go over each directory in 'rpctest_results' and make a mapping
        # { timestamp => link }
        foreach (new DirectoryIterator(BASE_DIR . 'rpctest_results') as $fileInfo) {
            if ($fileInfo->isDir() && !$fileInfo->isDot()) {
                $dir_name = $fileInfo->getFilename();
                make_mapping('/rpc_test_results' . '/' . $dir_name, $dir_name);
            }
        }

        krsort($to_sorted_dates, SORT_NUMERIC); # sort a map

        ?>

        <ul>
            <?php foreach ($to_sorted_dates as $timestamp => $link) : ?>
                <li>
                    <a href="<?php echo $link ?>"><?php
                                                    $date = new DateTime();
                                                    $date->setTimestamp($timestamp);
                                                    echo $date->format('Y-m-d H:i:s');
                                                    ?></a>
                </li>

            <?php endforeach ?>

        </ul>
    </nav>
</div>