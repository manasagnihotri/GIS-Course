---
layout: default
title: Home
---

# QMSS 5070: GIS and Spatial Analysis

Spring '26, Columbia University

**Course hub:** All slides, labs, homework, recordings, and reference documents are linked from this page.

## Start here

<div class="start-here" markdown="1">

* {% include material_link.html key="syllabus" label="Syllabus (Spring 2026)" %}
* {% include material_link.html key="cheatsheet" label="GIS cheat sheet" %}
* [Full schedule](#schedule)
* [Required software](#software)
* [TA office hours](#teaching-assistant) (Fridays 10:00 AM – 12:00 PM, Google Meet)

</div>

---

## Course Overview

The course introduces map-making skills, utilization of spatial data, and spatial analysis in policy applications. It emphasizes the interdisciplinary nature of Geographic Information Systems (GIS), which have become an increasingly helpful tool for observing and analyzing social and physical phenomena over space. Most of the physical and social sciences, as well as multiple professions, are expanding the infrastructure of GIS data that allows for new interdisciplinary analyses to occur and for unexamined potential spatial relationships to be uncovered. This is especially true for social scientific analyses, where a wealth of spatial data on cultural, economic, physical, and demographic characteristics remains unexamined but is easily accessible from many sources. It covers introductory concepts and tools related to Geographic Information Systems (GIS), including spatial data acquisition, gathering and analyzing Census population data, spatial data management, and spatial data analysis.

A primary goal of this course is to provide a relatively non-threatening introduction to GIS and its relation to hypothesis testing using statistical software in R. Students will learn to create and interpret thematic maps through hands-on experience with QGIS mapping software. Advanced topics will include spatial construction of data and the use of spatial data in quantitative applications to answer real-world problems. We will cover a range of GIS tools across various fields, including public policy, sociology, political science, and criminology, highlighting the breadth and depth of the course's subject matter. Lastly, the course will uncover critical GIS practices related to social and racial justice. Importantly, the course is designed to be accessible to students with no previous GIS or other spatial data analysis background. While no specific prerequisites are required, students should have taken at least one prior course in statistics.

In this course we will answer the following questions:

* How are spatial data structures different from traditional data structures?
* How do we acquire, manage, and analyze spatial data?
* How can GIS tools be applied to real-world public policy and social science problems?
* How do we create effective maps and visualizations to communicate spatial data?

## Instructor

Edwin Grimsley, Ph.D.  
Office Hours: after class or via Calendly appointment  
Virtual Office Hours on Zoom: Please email to schedule an appt. time and Zoom link on other days and times – https://columbiauniversity.zoom.us/j/2400680218  
E-mail: eg3033@columbia.edu (primary contact); edwin.grimsley@baruch.cuny.edu (secondary contact)

## Teaching Assistant {#teaching-assistant}

Manas Agnihotri: maa2416@columbia.edu  
Office Hours: Fridays, 10:00 AM – 12:00 PM via Google Meet  
[Google Meet Link](https://meet.google.com/kvt-cwti-ehs)

## Prerequisites

No previous GIS experience is required; however, at least one prior course in statistics (preferably including linear regression) is recommended.

## Time

Tuesdays, 12:10 PM – 2:00 PM  
302 Fayweather Hall

## Exams

Midterm: Handed out in Week 7, due Week 8  
Final Paper: Due Week 15 (May 8, Friday) - In lieu of a final exam, you will produce a research paper that applies spatial methods learned in class.

## Grade Breakdown

* 50% Homework Assignments (8 total, lowest score dropped)
* 20% Midterm Exam
* 15% Final Paper
* 5% Research Presentation
* 10% Attendance & Class Participation

## Late Submission Policy

Late homework will only be accepted under special circumstances and with prior instructor approval. Since content builds weekly, it is crucial to maintain the pace.

## Collaboration/Copying Policy

All assignments will be done individually. We will enforce this policy when checking the assignments (we use a code similarity system). Maintain the highest standards of honesty. Plagiarism or cheating in any form will not be tolerated and may result in failing the course.

## Course Materials

### Required Books
(All available as open source materials or through Columbia University Library)

1. **Essentials of Geographic Information Systems**  
   Author(s): Jonathan E. Campbell & Michael Shin  
   Edition: Version 1.0 (open textbook / online edition)  
   Publisher: Saylor Foundation  
   Available at: https://saylordotorg.github.io/text_essentials-of-geographic-information-systems/

2. **The SAGE Handbook of Spatial Analysis**  
   Editors: A. Stewart Fotheringham & Peter A. Rogerson  
   Publisher: SAGE Publications  
   Year: 2008  
   Available as PDF through Columbia University Library

### Recommended Books
* Steven J. Steinberg and Sheila L. Steinberg. 2006. GIS: Geographic Information Systems for the Social Sciences. Thousand Oaks, CA: Sage Publications.
* Fotheringham, A. Stewart, Chris Brunsdon and Martin Charlton. 2000. Quantitative Geography: Perspectives on Spatial Data Analysis. London, UK: Sage Publications
* Mitchell, Andy. 1999. The ESRI Guide to GIS Analysis, Volume 1: Geographic Patterns and Relationships. Redlands, CA: ESRI Press.
* Mitchell, Andy. 2005. The ESRI Guide to GIS Analysis, Volume 2: Spatial Measurements and Statistics. Redlands, CA: ESRI Press.

### Software {#software}
* QGIS (primary open-source GIS software)
* ArcGIS Pro (optional if provided license from QMSS)
* GeoDa (for exploratory spatial data analysis)
* R (for statistical tests and spatial packages)

(Note: Occasional Python examples may be given, but no prior Python experience is necessary.)

## Schedule {#schedule}

*This schedule is updated as materials are released. Bookmark this page.*

<div class="schedule-table-wrap" markdown="1">

| Week | Topic | Slides | Lab materials | Homework | Lab recording |
| ---- | ----- | ------ | ------------- | -------- | ------------- |
| 1 (Jan 20) | Orientation to Spatial Thinking & What Is GIS? | {% include material_link.html key="slide_1" label="Slides" %} | — | {% include material_link.html key="hw1" label="HW #1" %} (Assigned) | — |
| 2 (Jan 27) | Making Maps – Basic Visualization | {% include material_link.html key="slide_2" label="Slides" %} | {% include material_link.html key="lab1" label="Lab 1 (ZIP)" %} | HW #1 Due. {% include material_link.html key="hw2" label="HW #2" %} (Assigned) | {% include drive_recording.html file_id="1Qhr5ALUgXbrIlQcTP5qE0gbcJ-Cxt86M" label="Lab 1: Choropleth" %}, {% include drive_recording.html file_id="1wSoL6jeJ1zSax6GRZWwKmdySGrRGwl9d" label="Lab 1: Print Layout" %} |
| 3 (Feb 3) | Exploring Spatial Data I | {% include material_link.html key="slide_3" label="Slides" %} | {% include material_link.html key="lab2" label="Lab 2 (ZIP)" %} | HW #2 Due. {% include material_link.html key="hw3" label="HW #3" %} (Assigned) | {% include drive_recording.html file_id="1iQC0XLdpdBzkz3tJL40F7kgwsA3kjJUB" label="Lab 2 Recording" %} |
| 4 (Feb 10) | Exploring Spatial Data II | {% include material_link.html key="slide_4" label="Slides" %} | {% include material_link.html key="lab3" label="Lab 3 (ZIP)" %} | {% include material_link.html key="hw3" label="HW #3" %} Due | {% include drive_recording.html file_id="1ULQ0eIYwoMw8tHiYcvOcCXRhG_NgJNfJ" label="Lab 3 Recording" %} |
| 5 (Feb 17) | Advanced Data Wrangling, CRS & Geocoding | {% include material_link.html key="slide_5" label="Slides" %} | {% include material_link.html key="lab4" label="Lab 4 (ZIP)" %} | {% include material_link.html key="hw4" label="HW #4" %} (Assigned) | {% include drive_recording.html file_id="1ZazNAmWP4L_MRearf01bOz1gRouo_K2D" label="Lab 4: Geocoding Basics" %}, {% include drive_recording.html file_id="1OLqSq4XzJtNV4Mz-WTtKRR2CS-NDG-9W" label="Lab 4: Part 2" %} |
| 6 (Feb 24) | ESDA, Point Patterns & Hotspots | {% include material_link.html key="slide_6" label="Slides" %} | {% include material_link.html key="lab5" label="Lab 5 (ZIP)" %} | HW #4 Due. {% include material_link.html key="hw5" label="HW #5" %} (Assigned) | — |
| 7 (Mar 3) | R for Spatial Data & Interactive Mapping | {% include material_link.html key="slide_7_8" label="Slides" %} | {% include material_link.html key="lab6" label="Lab 6 (ZIP)" %} | Midterm distributed (link TBA) | — |
| 8 (Mar 10) | Midterm Due & Research Design | — | {% include material_link.html key="lab7" label="Lab 7 (ZIP)" %} | Midterm Due; HW #6 Assigned (Due Friday, March 14) — link TBA | — |
| 9 (Mar 24) | Spatial Autocorrelation | {% include material_link.html key="slide_9" label="Slides" %} | {% include material_link.html key="lab8" label="Lab 8 (ZIP)" %} | HW #7 Assigned — link TBA | {% include drive_recording.html file_id="1hgVKaiKJhrcO-tvcJlyggiMYt8Y72CZf" label="Lab 8: GeoDa" %}, {% include drive_recording.html file_id="1D-DAiOqBCzMLtcU4pmRePWNk4CBj7sb_" label="Lab 8: R" %} |
| 10 (Mar 31) | Regression & Spatial Dependence | Slides TBA | {% include material_link.html key="lab9" label="Lab 9 (ZIP)" %} | HW #7 Due; HW #8 Assigned — links TBA | — |
| 11 (Apr 7) | Advanced Spatial Models | Slides TBA | {% include material_link.html key="lab10" label="Lab 10 (ZIP)" %} | — | — |
| 12 (Apr 14) | Research Workshop | — | {% include material_link.html key="lab11" label="Lab 11 (ZIP)" %} | HW #8 Due — link TBA | — |
| 13 (Apr 21) | Final Presentations | — | — | — | — |
| 14 (Apr 28) | Final Presentations | — | {% include material_link.html key="lab12" label="Lab 12 (ZIP)" %} | — | — |
| 15 (May 8, Friday) | Final Paper Due | — | — | {% include material_link.html key="final_paper" label="Final Paper" %} Due | — |

</div>

**Note:** March 17 – Spring Break (NO CLASS)

## Lab recordings

All available lab session recordings (also linked in the schedule above):

{% for rec in site.data.drive_links.recordings %}
* Week {{ rec.week }} — {% include drive_recording.html file_id=rec.file_id label=rec.label %}
{% endfor %}

*Additional recordings will be posted as they become available.*
