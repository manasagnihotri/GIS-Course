---
layout: default
title: Home
---

<header class="page-hero">
  <h1>QMSS 5070: GIS and Spatial Analysis</h1>
  <p class="page-hero__subtitle">One place for slides, labs, homework, recordings, and course information.</p>
</header>

{% include quick_links.html %}

---

<section class="course-section" id="materials">
  <h2>Weekly materials</h2>
  <p class="section-lead">Each week lists slides, lab files, homework, and lab recordings in the same format. Bookmark this page and use the sidebar to jump to a week.</p>
  <div class="week-cards">
    {% for w in site.data.schedule.weeks %}
      {% include week_card.html week=w %}
    {% endfor %}
  </div>
  {% for note in site.data.schedule.notes %}
  <p class="schedule-note"><strong>Note:</strong> {{ note }}</p>
  {% endfor %}
</section>

<section class="course-section" id="recordings">
  <h2>Lab recordings</h2>
  <p class="section-lead">Video walkthroughs grouped by week (also linked inside each week card above).</p>
  {% include recordings_list.html %}
</section>

<section class="course-section" id="resources">
  <h2>Downloads</h2>
  <div class="download-grid">
    <div class="download-item">
      <h3>Course documents</h3>
      <ul>
        <li>{% include material_link.html key="syllabus" label="Syllabus (Spring 2026)" %}</li>
        <li>{% include material_link.html key="cheatsheet" label="GIS cheat sheet (PDF)" %}</li>
        <li>{% include material_link.html key="final_paper" label="Final paper assignment" %}</li>
      </ul>
    </div>
    <div class="download-item">
      <h3>Homework</h3>
      <ul>
        <li>{% include material_link.html key="hw1" label="HW #1" %}</li>
        <li>{% include material_link.html key="hw2" label="HW #2" %}</li>
        <li>{% include material_link.html key="hw3" label="HW #3" %}</li>
        <li>{% include material_link.html key="hw4" label="HW #4" %}</li>
        <li>{% include material_link.html key="hw5" label="HW #5" %}</li>
        <li>HW #6–#8 — <span class="muted">links posted when released</span></li>
      </ul>
    </div>
  </div>
</section>

<section class="course-section" id="about">
  <h2>About the course</h2>
  <details class="info-panel" open>
    <summary>Course overview</summary>
    <div class="info-panel__body">
      <p>The course introduces map-making skills, utilization of spatial data, and spatial analysis in policy applications. It emphasizes the interdisciplinary nature of Geographic Information Systems (GIS), which have become an increasingly helpful tool for observing and analyzing social and physical phenomena over space.</p>
      <p>A primary goal is a relatively non-threatening introduction to GIS and its relation to hypothesis testing using R. Students learn thematic mapping with QGIS and advanced spatial data construction and analysis for real-world policy and social science problems.</p>
      <p><strong>Key questions:</strong></p>
      <ul>
        <li>How are spatial data structures different from traditional data structures?</li>
        <li>How do we acquire, manage, and analyze spatial data?</li>
        <li>How can GIS tools be applied to public policy and social science problems?</li>
        <li>How do we create effective maps and visualizations?</li>
      </ul>
    </div>
  </details>
  <details class="info-panel">
    <summary>Prerequisites &amp; meeting time</summary>
    <div class="info-panel__body">
      <p><strong>Prerequisites:</strong> No prior GIS experience required; one prior statistics course (linear regression recommended) is helpful.</p>
      <p><strong>When:</strong> Tuesdays, 12:10 PM – 2:00 PM · 302 Fayweather Hall</p>
    </div>
  </details>
  <details class="info-panel" id="software">
    <summary>Required software</summary>
    <div class="info-panel__body">
      <ul>
        <li><strong>QGIS</strong> — primary open-source GIS</li>
        <li><strong>R</strong> — spatial packages and statistics</li>
        <li><strong>GeoDa</strong> — exploratory spatial data analysis</li>
        <li><strong>ArcGIS Pro</strong> — optional (QMSS license if available)</li>
      </ul>
      <p class="muted">Occasional Python examples may appear; no prior Python required.</p>
    </div>
  </details>
  <details class="info-panel">
    <summary>Textbooks</summary>
    <div class="info-panel__body">
      <h4>Required</h4>
      <ol>
        <li><strong>Essentials of Geographic Information Systems</strong> — Campbell &amp; Shin (<a href="https://saylordotorg.github.io/text_essentials-of-geographic-information-systems/">open textbook</a>)</li>
        <li><strong>The SAGE Handbook of Spatial Analysis</strong> — Fotheringham &amp; Rogerson (PDF via Columbia Library)</li>
      </ol>
      <h4>Recommended</h4>
      <ul>
        <li>Steinberg &amp; Steinberg (2006), <em>GIS for the Social Sciences</em></li>
        <li>Fotheringham, Brunsdon &amp; Charlton (2000), <em>Quantitative Geography</em></li>
        <li>Mitchell (1999, 2005), <em>ESRI Guide to GIS Analysis</em> Vols. 1–2</li>
      </ul>
    </div>
  </details>
</section>

<section class="course-section" id="people">
  <h2>Instructor &amp; TA</h2>
  <div class="people-grid">
    <div class="person-card">
      <h3>Instructor</h3>
      <p class="person-name">Edwin Grimsley, Ph.D.</p>
      <ul class="person-details">
        <li>Office hours: after class or via Calendly</li>
        <li>Zoom: <a href="https://columbiauniversity.zoom.us/j/2400680218">schedule by email</a></li>
        <li>Email: <a href="mailto:eg3033@columbia.edu">eg3033@columbia.edu</a></li>
      </ul>
    </div>
    <div class="person-card" id="teaching-assistant">
      <h3>Teaching Assistant</h3>
      <p class="person-name">Manas Agnihotri</p>
      <ul class="person-details">
        <li>Email: <a href="mailto:maa2416@columbia.edu">maa2416@columbia.edu</a></li>
        <li>Office hours: Fridays, 10:00 AM – 12:00 PM</li>
        <li><a href="https://meet.google.com/kvt-cwti-ehs">Google Meet link</a></li>
      </ul>
    </div>
  </div>
</section>

<section class="course-section" id="policies">
  <h2>Policies &amp; grading</h2>
  <div class="policy-grid">
    <div class="policy-card">
      <h3>Grading</h3>
      <ul>
        <li>50% — Homework (8 total, lowest dropped)</li>
        <li>20% — Midterm</li>
        <li>15% — Final paper</li>
        <li>5% — Research presentation</li>
        <li>10% — Attendance &amp; participation</li>
      </ul>
    </div>
    <div class="policy-card">
      <h3>Exams &amp; deadlines</h3>
      <ul>
        <li><strong>Midterm:</strong> distributed Week 7, due Week 8</li>
        <li><strong>Final paper:</strong> due Week 15 (Friday, May 8)</li>
      </ul>
    </div>
    <div class="policy-card">
      <h3>Late work</h3>
      <p>Late homework only with prior instructor approval. Content builds weekly—stay on pace.</p>
    </div>
    <div class="policy-card">
      <h3>Collaboration</h3>
      <p>All assignments are individual. Code similarity is checked. Plagiarism or cheating may result in course failure.</p>
    </div>
  </div>
</section>
