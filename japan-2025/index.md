---
comments: false
layout: page
title: "Trip: Japan 2025"
category: japan-2025
--- 

<ul id='archive'>{% assign sorted_posts = site.posts | where: "categories" , page.category %}
{% for post in sorted_posts %}
    {% include archives.html %}
{% endfor %}
</ul>