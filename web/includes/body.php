<body>
    <?php include BASE_DIR . '/includes/components/banner.php'; ?>

    <div id="app" class="container">

        <?php

        $uri = $_SERVER["REQUEST_URI"];

        function resolve_page()
        {
            global $uri;


            $result = '404.php'; # 404 for all routes by default 

            # if any of the uris matched valid routes
            # render the page corresponding to a given route
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