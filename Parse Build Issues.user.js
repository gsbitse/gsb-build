// ==UserScript==
// @name       Parse Build Issues
// @namespace  http://stanfordgsb.jira.com/
// @version    0.1
// @description  Shows notes for release builds
// @match      https://stanfordgsb.jira.com/*
// @copyright  2014+, GSB
// @require     http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js
// @resource    jqUI_CSS  http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css
// @resource    IconSet1  http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/images/ui-icons_222222_256x240.png
// @resource    IconSet2  http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/images/ui-icons_454545_256x240.png
// @grant       GM_addStyle
// @grant       GM_getResourceText
// @grant       GM_getResourceURL
// ==/UserScript==

(function($) {
  $(document).ready(function() {
    $('body').bind('DOMSubtreeModified.event1', modified);
  });
  
  function modified() {
    $(this).unbind('DOMSubtreeModified.event1');
    setTimeout(function(){
      addNotes();
      $('body').bind('DOMSubtreeModified.event1',modified);
    },1000);
  }
  
  function addNotes() {
    if ($('h1.search-title').text() == 'Ready For Release') {
      if(!$('div#notes-area').length) {
     	$notesContainer = $('<div id="notes-container"></div>');
        $startLink = $('<button id="notes-start-link">Show Notes</button>');
        $notesContainer.prepend($startLink);
        $notesArea = $('<div id="notes-area"></div>');
        $notesContainer.append($notesArea);
        $('div.navigator-group').prepend($notesContainer);
        $notesArea.hide();
        
        $startLink.button().click(function(e) {
          e.preventDefault();
          issues = {};
          $('#issuetable tbody tr').each(function(index, item) {
            var issue = {};
            
            $issueLink = $(item).find('td.summary a.issue-link:not(.parentIssue)');
            issue.number = $issueLink.data('issue-key');
            issue.link = 'https://stanfordgsb.jira.com' + $issueLink.attr('href');
            issue.text = $issueLink.text();
            issue.owner = $(this).find('td.assignee a').text();
            
            $parentIssue = $(item).find('td.summary a.parentIssue');
            if ($parentIssue.length) {
              $.ajax({
                async: false,
                type: 'GET',
                url: 'https://stanfordgsb.jira.com' + $parentIssue.attr('href'),
                success: function(data) {
                  issue.parentTitle = $(data).find('h1#summary-val').text();
                }
              });
            }
            issues[issue.owner] = issues[issue.owner] || {};
            issues[issue.owner][index] = issue;
          });
          var html = '<ul>';
          for (assignee in issues) {
            html += '<li>' + assignee + '<ul>';
            for (index in issues[assignee]) {
              issue = issues[assignee][index];
              html += '<li>';
              if (issue.parentTitle) {
                html += issue.parentTitle + ': ';
              }
              html += '<a href="' + issue.link + '">(' + issue.number + ') ' + issue.text + '</a></li>'
            }
            
            html += '</ul></li>';
          }
          html += '</ul>';
          
          $notesArea.html(html);
          
          //--- Activate the dialog.
          $notesArea.dialog({
            modal:      true,
            title:      "Copy and Paste the Text Below",
            minWidth:   600,
            zIndex:     83666   //-- This number doesn't need to get any higher.
          });
        });
      }
    }
    else {
      $('div#notes-container').empty();
    }
  }
    
  /**********************************************************************************
  EVERYTHING BELOW HERE IS JUST WINDOW DRESSING (pun intended).
  **********************************************************************************/

  /*--- Process the jQuery-UI, base CSS, to work with Greasemonkey (we are not on a server)
      and then load the CSS.
  
      *** Kill the useless BG images:
          url(images/ui-bg_flat_0_aaaaaa_40x100.png)
          url(images/ui-bg_flat_75_ffffff_40x100.png)
          url(images/ui-bg_glass_55_fbf9ee_1x400.png)
          url(images/ui-bg_glass_65_ffffff_1x400.png)
          url(images/ui-bg_glass_75_dadada_1x400.png)
          url(images/ui-bg_glass_75_e6e6e6_1x400.png)
          url(images/ui-bg_glass_95_fef1ec_1x400.png)
          url(images/ui-bg_highlight-soft_75_cccccc_1x100.png)
  
      *** Rewrite the icon images, that we use, to our local resources:
          url(images/ui-icons_222222_256x240.png)
          becomes
          url("' + GM_getResourceURL ("IconSet1") + '")
          etc.
  */
  var iconSet1    = GM_getResourceURL ("IconSet1");
  var iconSet2    = GM_getResourceURL ("IconSet2");
  var jqUI_CssSrc = GM_getResourceText ("jqUI_CSS");
  jqUI_CssSrc     = jqUI_CssSrc.replace (/url\(images\/ui\-bg_.*00\.png\)/g, "");
  jqUI_CssSrc     = jqUI_CssSrc.replace (/images\/ui-icons_222222_256x240\.png/g, iconSet1);
  jqUI_CssSrc     = jqUI_CssSrc.replace (/images\/ui-icons_454545_256x240\.png/g, iconSet2);
  
  GM_addStyle (jqUI_CssSrc);
  
  
  //--- Add some custom style tweaks.
  GM_addStyle ( (<><![CDATA[
    div.ui-widget-overlay {
      background: grey;
      opacity:    0.6;
    }
    div#notes-area a {
      color: blue;
    }
  ]]></>).toString () );
})(jQuery);
