# pjey

''A simple pagination for jekyll 3.x with support for tags and categories.''

*Unfortunately the documentation of jekyll (https://jekyllrb.com/docs/pagination/) says:*\
**''Pagination does not support tags or categories''** Pagination pages through every post in the posts variable unless a post has hidden: true in its YAML Front Matter. It does not currently allow paging over groups of posts linked by a common tag or category. It cannot include any collection of documents because it is restricted to posts.

So, this is a simple paginatin tool for structuring your posts with tags and categories AND using a pagination for that.

**ToDo**
- add multilingual support (use "lang"-key in head)
- add support for data
- add support for pages

**Notes**\
*Testing:* For testing we generate XML-Data which makes it easier to parse results with less dependencies ;).


A bootstrap pagination could look like this one:

```
{% if pjey.page.total_pages > 1 %}
  <nav>
    <ul class="pagination">
      {% if pjey.page.previous %}
        <li><a class="prev" href="/{{ pjey.page.previous.path | prepend: site.baseurl }}">&laquo;</a></li>
      {% endif %}

      {% for cur_page in (1..pjey.page.total_pages) %}
        {% if cur_page == 1 and pjey.page.page != 1 %}
          <li><a href="/{{ pjey.page.root.path | prepend: site.baseurl }}">{{ cur_page }}</a></li>
        {% elsif cur_page != pjey.page.page %}
          <li><a href="/{{ pjey.page.permalink | replace:':page',cur_page | prepend: site.baseurl }}">{{ cur_page }}</a></li>
        {% else %}
          <li class="active"><span>{{ cur_page }}</span></li>
        {% endif %}
      {% endfor %}
      
      {% if pjey.page.next %}
        <li><a class="next" href="/{{ pjey.page.next.path | prepend: site.baseurl }}">&raquo;</a></li>
      {% endif %}
    </ul>
  </nav>
{% endif %}
```