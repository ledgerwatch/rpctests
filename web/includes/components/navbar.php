<div id="navbar" class="section">
    <nav>
        <ul>
            <?php
            $links = [
                'root' => '/',
                'rpc test results' => '/rpc_test_results',
            ];

            foreach ($links as $name => $link) : ?>
                <li class="">
                    <a href="<?php echo $link ?>"><?php echo $name ?></a>
                </li>

            <?php endforeach ?>
        </ul>
    </nav>
</div>