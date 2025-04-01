const mongoose = require('mongoose');
const Schema = mongoose.Schema;

/**
 * WordPress Theme Schema
 * Defines the structure for WordPress themes created with AutoLaunch Studio
 */
const WordPressThemeSchema = new Schema({
  // Basic theme information
  name: {
    type: String,
    required: true,
    trim: true
  },
  slug: {
    type: String,
    required: true,
    trim: true,
    lowercase: true,
    unique: true
  },
  description: {
    type: String,
    required: true
  },
  version: {
    type: String,
    default: '1.0.0'
  },
  author: {
    name: String,
    email: String,
    url: String
  },
  
  // Theme details
  screenshot: String,
  previewUrl: String,
  demoUrl: String,
  downloadUrl: String,
  
  // WordPress compatibility
  requires: {
    type: String,
    default: '5.0'
  },
  tested: {
    type: String,
    default: '6.4'
  },
  
  // Theme features
  features: [{
    type: String,
    enum: [
      'custom-logo',
      'post-thumbnails',
      'custom-header',
      'custom-background',
      'nav-menus',
      'automatic-feed-links',
      'editor-style',
      'widgets',
      'responsive',
      'rtl-language-support',
      'translation-ready',
      'block-editor-styles',
      'wide-blocks',
      'full-site-editing'
    ]
  }],
  
  // Theme templates
  templates: [{
    name: String,
    file: String,
    description: String
  }],
  
  // Theme style variations
  styleVariations: [{
    name: String,
    description: String,
    colors: {
      primary: String,
      secondary: String,
      background: String,
      text: String
    }
  }],
  
  // Theme options
  options: {
    customizer: {
      type: Boolean,
      default: true
    },
    blockEditor: {
      type: Boolean,
      default: true
    },
    fullSiteEditing: {
      type: Boolean,
      default: false
    },
    customFonts: {
      type: Boolean,
      default: false
    },
    customColors: {
      type: Boolean,
      default: true
    }
  },
  
  // Theme structure
  structure: {
    hasCustomPostTypes: {
      type: Boolean,
      default: false
    },
    hasCustomTaxonomies: {
      type: Boolean,
      default: false
    },
    hasShortcodes: {
      type: Boolean,
      default: false
    },
    hasWidgets: {
      type: Boolean,
      default: false
    },
    hasCustomizer: {
      type: Boolean,
      default: true
    }
  },
  
  // Theme files
  files: {
    css: [String],
    js: [String],
    php: [String],
    images: [String],
    fonts: [String]
  },
  
  // Theme status
  status: {
    type: String,
    enum: ['draft', 'pending', 'published', 'archived'],
    default: 'draft'
  },
  
  // Creation and modification timestamps
  createdBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  }
}, { timestamps: true });

// Add text search index
WordPressThemeSchema.index({
  name: 'text',
  description: 'text',
  'author.name': 'text'
});

// Create slug from name if not provided
WordPressThemeSchema.pre('save', function(next) {
  if (!this.slug && this.name) {
    this.slug = this.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-$/, '');
  }
  next();
});

module.exports = mongoose.model('WordPressTheme', WordPressThemeSchema);
