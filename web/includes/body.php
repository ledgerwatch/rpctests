<body>
    <?php include BASE_DIR . '/includes/components/banner.php'; ?>

    <div id="app" class="container">

        <?php
        /**
         * This script wraps all possible pages in it.
         * Possible pages are in 'pages' folder.
         * To add another page make sure to add its uri path to
         * '$valid_routes' in 'resolve_page' function. 
         * 
         * Goal of this logic:
         *  render a page depending on request uri
         * 
         * Logic:
         *  1. get the request uri($uri)
         *  2. test the $uri against $valid_routes, return the $page  
         *  3. render/include this $page
         */

        $uri = $_SERVER["REQUEST_URI"]; # 1 get request uri

        function resolve_page(string $_uri)
        {

            $result = '404.php'; # 404 for all routes by default 

            # if any of the uris matched valid routes
            # render the page corresponding to a given route
            $valid_routes = [
                # /
                '/^\/$/' => 'root.php', 
                # /rpc_test_results
                '/^\/rpc_test_results\/?$/' => 'rpc_test_results.php',
                # /rpc_test_results/replayYYYYMMDD_HHMMSS 
                # see qa_scripts/rpctest_replay.sh variable $RESULTS_DIR_NAME 
                # for date format generation
                '/^\/rpc_test_results\/replay\d{8}\_\d{6}\/?$/' => 'replay.php',
            ];

            foreach ($valid_routes as $key => $value) {
                if (preg_match($key, $_uri)) {
                    $result = $value;
                }
            }

            return $result;
        }

        $page = resolve_page($uri); # 2 get the corresponding page

        $replay = ""; # this variable is used in 'replay.php' page
        if ($page === 'replay.php') {
            # take 'replayYYYYMMDD_HHMMSS' part out of
            # '/rpc_test_results/replayYYYYMMDD_HHMMSS'
            # and set it to $replay
            preg_match(
                '/^\/rpc_test_results\/(replay\d{8}\_\d{6})\/?$/',
                $uri,
                $matches,
            );
            $replay = $matches[1];
        }

        include BASE_DIR . 'includes/pages/' . $page; # 3 render the page
        ?>
    </div>