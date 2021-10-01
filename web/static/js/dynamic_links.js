let global_map = {};
let tabs_flags = {};

function switch_tabs() {

}
/**
 *  
 * @param {String} name
 * @param {HTMLUListElement} ul
 * @param {HTMLDivElement} tab_content
*/
function make_li(name, ul, tab_content) {
    let li = document.createElement('li');
    let anchor = document.createElement('a');

    li.id = name


    anchor.className = "pseudo-link"
    anchor.innerHTML = name;

    anchor.onclick = function () {
        for (const child of ul.getElementsByTagName('li')) {
            child.classList.remove('active');
        }

        for (const child of tab_content.getElementsByClassName('content-tab')) {
            if (child.classList.contains(name)) {
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

function make_content(name, content) {
    let div = document.createElement('div');

    div.className = 'content-tab';
    div.classList.add(name);

    let lines = "";
    for (const line of content) {


        if (line === "\n") {
            let br = document.createElement("br");
            div.appendChild(br);
        } else {
            let p = document.createElement('p');
            p.classList.add("stdout");
            p.innerHTML = decorate_line(line, p);
            div.appendChild(p);
        }

        // lines += line;

    }

    div.style.display = "none";
    // div.innerHTML = lines;
    return div;
}

function handle_files_content(map) {

    if (!map) {
        throw "Expected map of file_name => file_content"
    }

    global_map = map;

    let tab_content = document.getElementById('dynamic-content');
    let ul = document.getElementById('dynamic-tabs');

    for (const [key, value] of Object.entries(map)) {
        tabs_flags[key] = false;
        tab_content.appendChild(make_content(key, value));
        ul.appendChild(make_li(key, ul, tab_content));
    }
}


const LOG_KIND = /^\[(\w+)\]/;
const DATE_TIME = /^\[?\w+\]?\s+\[(\d{2}-\d{2})\|(\d{2}\:\d{2}\:\d{2}\.\d+)\]/;
const LOG_EMPH = /(\s+\w+)\=/gm;
const LOG_EMPH_WORD = /\s+(\w+)/;
const LOG_TITLE = /^\[?\w+\]?\s+\[\d{2}-\d{2}\|\d{2}\:\d{2}\:\d{2}\.\d+\]\s+?(.+)/;
/**
 * removes new lines from line if line itself is not newline
 * adds additional styles to make it look better (log style)
 * @param {String} line
 * @param {HTMLParagraphElement} p_tag
 */
function decorate_line(line, p_tag) {

    let log_match = line.match(LOG_KIND);

    let log_kind, date, time;

    if (log_match) { // means that this is a stdout log
        log_kind = log_match[1];

        let kind_span = document.createElement('span');
        kind_span.innerText = log_kind;
        kind_span.classList.add("is-log");

        if (log_kind === "WARN") kind_span.classList.add("log-warn");
        if (log_kind === "INFO") kind_span.classList.add("log-info");
        if (log_kind === "DBUG") kind_span.classList.add("log-dbug");
        if (log_kind === "EROR") kind_span.classList.add("log-eror");
        // TODO log_kind === "ERRO" || log_kind === "ERR"



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



        let to_emphasize = []

        // if (to_emphasize) {
        //     for (const pair of to_emphasize) {
        //         let [word_span, word] = pair;
        //         line = line.replace(word_match, word_span.outerHTML);
        //     }
        // }
        let info_match = line.match(LOG_EMPH);
        if (info_match) {
            console.log(info_match);
            for (let i = 0; i < info_match.length; i++) {

                let word = info_match[i]
                let total_size = word.length - 2; // exclude "-" and space
                let word_match = word.match(LOG_EMPH_WORD)[1];

                let word_span = document.createElement('span');
                word_span.innerText = word_match;
                word_span.classList.add("log-emph");

                let word_len = word_match.length;
                if (total_size - word_len > 8) {
                    word_span.style.paddingLeft = `${total_size - word_len}px`;
                } else {
                    word_span.style.paddingLeft = `8px`;
                }


                line = line.replace(word, `${word_span.outerHTML}=`);
            }
        }
        line = line.replace(LOG_KIND, kind_span.outerHTML);
        line = line.replace(date, date_span.outerHTML);
        line = line.replace(time, time_span.outerHTML);
    }


    // if (date_match) {

    // }

    return line;
}