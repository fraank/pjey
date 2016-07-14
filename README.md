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