/**
 * Created by junjun on 2018/5/26.
 */

console.log("loaded...")

var srt_url = `https://video.google.com/timedtext?hl=zh-TW&lang=zh-TW&v=kktBxP3656o&fmt=vtt`

function load_subtitle(url)
{
    console.log("load_subtitle:",url)
    jQuery.ajax({
        type: "GET",
        url: url,
        // dataType: "html/text",
        success: function(data){
            //console.log("success",data);

            var parser = new WebVTTParser();
            var tree = parser.parse(data);
            console.log("tree",tree);
            window.vtt = tree;
        },
        complete:function(data)
        {
            console.log("complete",data);
        }

    });
}


var jquery_url = "https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"
var vtt_url = 'https://quuz.org/webvtt/parser.js'

var urls = [jquery_url,vtt_url]
for(var i = 0; i < urls.length; i++)
{
    let script = document.createElement('script');
    script.src = urls[i];
    document.getElementsByTagName('head')[0].appendChild(script);

}

var interval = null;

setTimeout( function() {
    console.log("window loaded");
    load_subtitle(srt_url);

    if(interval != null)
    {
        clearInterval(interval);
    }

    interval = setInterval(function(){

            var v = document.getElementsByTagName("video")[0]
            var vtt = window.vtt;
            if( vtt && v )
            {
                var cur_time = v.getCurrentTime();


                for(let i = 0; i < vtt.cues.length; i++)
                {
                    if(cur_time > vtt.cues[i].endTime)
                        continue;
                    else
                    {
                        if(window.vtt_index != i)
                        {
                            console.log(cur_time);
                            window.vtt_index = i;
                            var cur_vtt = vtt.cues[i];
                            console.log(cur_vtt.text);

                            if(window.vvt_node)
                                window.vvt_node.remove();

                            window.vvt_node = jQuery(`<div id="vtt_node" style="width:100%;padding:4px;font-size:14px;z-index:1024;position:absolute; bottom:50px"><p style="text-align: center">${cur_vtt.text}</p></div>`);

                            jQuery("#player-api").append(window.vvt_node);
                        }
                        break;
                    }
                }
            }
    },500);
},3000);

