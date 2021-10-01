<?php

include BASE_DIR . '/includes/components/navbar.php';

?>
<div class="section">

    <nav id="replays-links">
        <h3>Replays: </h3>
        <?php

        $rx_date_time = '/^replay(\d{8})\_(\d{6})\/?$/';
        $to_sorted_dates = [];

        function handle_date(string $link, string $str_date)
        {
            global $rx_date_time;
            global $to_sorted_dates;

            preg_match($rx_date_time, $str_date, $matches);
            assert(count($matches) >= 3);

            $timestamp = strtotime(implode(" ", array_slice($matches, 1)));
            $to_sorted_dates[$timestamp] = $link;
        }


        foreach (new DirectoryIterator(BASE_DIR . 'rpctest_results') as $fileInfo) {
            if ($fileInfo->isDir() && !$fileInfo->isDot()) {
                $dir_name = $fileInfo->getFilename();
                handle_date('/rpc_test_results' . '/' . $dir_name, $dir_name);
            }
        }

        krsort($to_sorted_dates, SORT_NUMERIC);

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