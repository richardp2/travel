---
comments: false
layout: page
title: "Trip: Cornwall 2012"
category: cornwall-2012
redirect_from:
 - /uk/cornwall/cornwall-2012/
---

<ul id='archive'>{% assign sorted_posts = (site.posts | where: "categories" , page.category) %}
{% for post in sorted_posts %}
    {% include archives.html %}
{% endfor %}
</ul>