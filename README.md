# Course Website

A Jekyll-based course website for GitHub Pages, similar to the CSEE4121 course site structure.

## Setup Instructions

### Prerequisites

- Ruby (version 2.7 or higher)
- Bundler gem

### Local Development

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Run Jekyll locally:**
   ```bash
   bundle exec jekyll serve
   ```

3. **View the site:**
   Open your browser to `http://localhost:4000`

### GitHub Pages Deployment

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Initial course website setup"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Navigate to Settings → Pages
   - Under "Source", select "Deploy from a branch"
   - Choose the `main` branch and `/ (root)` folder
   - Click Save

3. **Wait for deployment:**
   - GitHub Pages will automatically build and deploy your site
   - Your site will be available at `https://[username].github.io/[repository-name]`
   - The first deployment may take a few minutes

### Customization

1. **Update course information:**
   - Edit `index.md` and replace all placeholders (marked with `[PLACEHOLDER]`)
   - Update `_config.yml` with your course name and description

2. **Add slides:**
   - Place PDF files in the `slides/` directory
   - Update links in the schedule table in `index.md`

3. **Add homework pages:**
   - Create `hw1.html`, `hw2.html`, etc. in the root directory
   - Link to them from the schedule table

4. **Customize styling:**
   - Edit `assets/css/style.css` to match your preferences

### File Structure

```
.
├── _config.yml          # Jekyll configuration
├── _layouts/            # HTML layouts
│   └── default.html     # Default page layout
├── index.md             # Homepage content
├── assets/              # Static assets
│   ├── css/
│   │   └── style.css   # Custom styles
│   └── audio/          # Audio files
├── slides/              # PDF slides directory
├── Gemfile              # Ruby dependencies
└── README.md           # This file
```

### Troubleshooting

- **Build errors:** Make sure all required gems are installed with `bundle install`
- **CSS not loading:** Ensure paths in `_layouts/default.html` use `relative_url` filter
- **GitHub Pages not updating:** Check the Actions tab for build errors

### Notes

- The site uses Jekyll 4.3 with a custom layout
- All content is written in Markdown
- The site is optimized for GitHub Pages deployment
- Custom CSS is included for academic styling

## Updating course materials

**Student-facing URL:** https://manasagnihotri.github.io/GIS-Course/

### Weekly updates (after each class)

1. Upload new files to the professor’s Google Drive folder (see [PROFESSOR_DRIVE_CHECKLIST.md](PROFESSOR_DRIVE_CHECKLIST.md)).
2. Edit [`_data/drive_links.yml`](_data/drive_links.yml):
   - Add new recording `file_id` entries under `recordings:`.
   - Paste professor Drive file IDs under `professor_drive:` when migrating off GitHub hosting.
   - Set `use_professor_drive: true` once all IDs are filled.
3. Update the schedule row in [`index.md`](index.md) if needed (e.g. replace “link TBA” with `{% include material_link.html %}`).
4. Test locally: `bundle exec jekyll serve` and click every link.
5. Commit and push to `main`; GitHub Actions deploys the site automatically.

### Professor Drive migration

Use [PROFESSOR_DRIVE_CHECKLIST.md](PROFESSOR_DRIVE_CHECKLIST.md) in the meeting with the instructor. After links are collected, fill `professor_drive` in `_data/drive_links.yml` and enable `use_professor_drive`.

### Link sources

| File | Purpose |
|------|---------|
| `_data/schedule.yml` | Weekly topics, homework notes, lab/slide keys |
| `_data/drive_links.yml` | File URLs (GitHub paths or professor Drive IDs) |
| `_includes/week_card.html` | Renders each week’s materials block |
| `index.md` | Page sections (materials, recordings, policies) |
| `PROFESSOR_DRIVE_CHECKLIST.md` | Inventory for Drive transfer (not shown on site) |

To add or edit a week, update `_data/schedule.yml` and the matching keys in `_data/drive_links.yml`.
