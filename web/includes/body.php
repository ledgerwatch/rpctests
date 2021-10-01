<body>
    <?php include BASE_DIR . '/includes/components/banner.php'; ?>

    <div id="app" class="container">

        <?php

        $uri = $_SERVER["REQUEST_URI"];

        function resolve_page()
        {
            // $uri = $_SERVER["REQUEST_URI"];
            global $uri;
            // echo $uri;

            $result = '404.php';

            $valid_routes = [
                '/^\/$/' => 'root.php',
                '/^\/rpc_test_results\/?$/' => 'rpc_test_results.php',
                '/^\/rpc_test_results\/replay\d{8}\_\d{6}\/?$/' => 'replay.php',
            ];

            foreach ($valid_routes as $key => $value) {
                if (preg_match($key, $uri)) {
                    $result = $value;
                }
            }

            return $result;
        }

        $page = resolve_page();
        $replay = "";
        if ($page === 'replay.php') {
            preg_match(
                '/^\/rpc_test_results\/(replay\d{8}\_\d{6})\/?$/',
                $uri,
                $matches,
            );
            $replay = $matches[1];
        }

        include BASE_DIR . 'includes/pages/' . $page;
        ?>
    </div>