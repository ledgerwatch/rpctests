/**
 * Creates clickable "link"/button so user can navigate between files. 
 *  
 * @param {String} name
 * @param {HTMLUListElement} ul
 * @param {HTMLDivElement} tab_content
 * @param {Number | null} exit_code
*/
function make_li(file_name, ul, tab_content, exit_code) {
    let li = document.createElement('li');
    let anchor = document.createElement('a');

    li.id = file_name

    if (exit_code !== null) {
        li.classList.add(exit_code === 0 ? "test-success" : "test-fail")
    }

    anchor.className = "pseudo-link"
    anchor.innerHTML = file_name;

    anchor.onclick = function () {
        for (const child of ul.getElementsByTagName('li')) {
            child.classList.remove('active');
        }

        for (const child of tab_content.getElementsByClassName('content-tab')) {
            if (child.classList.contains(file_name)) {
                child.style.display = "block";
            } else {
                child.style.display = "none";
            }
        }

        li.classList.add('active');
    }

    li.appendChild(anchor);

    return li;
}

/**
 * Creates html tags and adds CSS selectors to them. So the content could be styled using CSS.
 * 
 * @param {String} file_name 
 * @param {Array.<String>} content  
 */
function make_content(file_name, content) {
    let div = document.createElement('div');

    div.className = 'content-tab';
    div.classList.add(file_name);

    let is_txt = file_name.substr(file_name.length - 3, 3) === "txt";

    let i = 0;
    let exit_code = null;
    if (is_txt) {
        // in .txt files first line is always exit code of the test
        // this exit code is used to style failed and succeeded tests
        exit_code = +content[i++];
    }

    for (; i < content.length; i++) {
        let line = content[i];

        if (line === "\n") {
            let br = document.createElement("br");
            div.appendChild(br);
        } else {
            let p = document.createElement('p');
            p.classList.add("stdout");
            p.innerHTML = decorate_line(line, p);
            div.appendChild(p);
        }
    }


    div.style.display = "none";

    return [div, exit_code];
}

// example log: 
// [INFO] [10-21|03:25:07.523] [txpool] stat                            block=5706749 pending=2574 baseFee=0 queued=8857 alloc_mb=2246 sys_mb=4532

// [INFO]
const LOG_KIND = /^\[(\w+)\]/;
// [INFO] [10-21|03:25:07.523]
const DATE_TIME = /^\[?\w+\]?\s+\[(\d{2}-\d{2})\|(\d{2}\:\d{2}\:\d{2}\.\d+)\]/;
// block= pending= baseFee= queued= alloc_mb= sys_mb=
const LOG_INFO = /(\s+\w+)\=/gm;
const LOG_WORD = /\s+(\w+)/;


/**
 * Takes a content line as an input. \
 * Adds additonal tags to it. \
 * Adds CSS seclectors to each line, so it could be styled using CSS.
 * 
 * @param {String} line
 */
function decorate_line(line) {

    let log_match = line.match(LOG_KIND);

    let log_kind, date, time;

    if (log_match) {
        log_kind = log_match[1];

        let kind_span = document.createElement('span');
        kind_span.innerText = log_kind;
        kind_span.classList.add("is-log");

        if (log_kind === "WARN") kind_span.classList.add("log-warn");
        if (log_kind === "INFO") kind_span.classList.add("log-info");
        if (log_kind === "DBUG") kind_span.classList.add("log-dbug");
        if (log_kind === "EROR") kind_span.classList.add("log-eror");


        // if this is a log, there has to be date and time
        let date_match = line.match(DATE_TIME);

        date = date_match[1];
        time = date_match[2];

        let date_span = document.createElement('span');
        let time_span = document.createElement('span');

        date_span.innerText = date;
        time_span.innerText = time;

        date_span.classList.add('log-date');
        time_span.classList.add('log-time');

        let info_match = line.match(LOG_INFO);
        console.log(info_match)
        if (info_match) {

            for (let i = 0; i < info_match.length; i++) {

                let info = info_match[i]

                let total_size = info.length - 2; // exclude space and "="
                let word_match = info.match(LOG_WORD)[1];

                let word_span = document.createElement('span');
                word_span.innerText = word_match;
                word_span.classList.add("log-emph");

                let word_len = word_match.length;
                if (total_size - word_len > 8) {
                    word_span.style.paddingLeft = `${total_size - word_len}px`;
                } else {
                    word_span.style.paddingLeft = `8px`;
                }

                line = line.replace(info, `${word_span.outerHTML}=`);
            }
        }
        line = line.replace(LOG_KIND, kind_span.outerHTML);
        line = line.replace(date, date_span.outerHTML);
        line = line.replace(time, time_span.outerHTML);
    }

    return line;
}

/**
 * "main" function. \
 * Receives a map object { file_name => file_content } from 'replay.php'.
 * Processes this map so file content could be displayed in the browser.
 * 
 * @param {Object} map 
 */
function handle_files_content(map) {

    if (!map) {
        throw "Expected map of type {'file_name': 'file_content'}"
    }

    let tab_content = document.getElementById('dynamic-content');
    let ul = document.getElementById('dynamic-tabs');

    for (const [file_name, content] of Object.entries(map)) {
        let [terminal, exit_code] = make_content(file_name, content)
        tab_content.appendChild(terminal);
        ul.appendChild(make_li(file_name, ul, tab_content, exit_code));
    }
}