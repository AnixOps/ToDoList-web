/**
 * Cloudflare Worker for serving static assets without KV dependency
 * This worker serves the built Vue.js SPA directly from the assets directory
 */

export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env)
  }
}

async function handleRequest(request, env) {
  const url = new URL(request.url)
  const pathname = url.pathname
  
  try {
    // For SPA routing - serve index.html for routes that don't have file extensions
    // This handles client-side routing for Vue Router
    if (!pathname.includes('.') && pathname !== '/') {
      // Serve index.html for SPA routes
      return env.ASSETS.fetch(new URL('/index.html', request.url))
    }
    
    // For static assets (CSS, JS, images, etc.) and root path
    return env.ASSETS.fetch(request)
    
  } catch (error) {
    // Fallback to index.html if asset not found (for SPA routing)
    try {
      const response = await env.ASSETS.fetch(new URL('/index.html', request.url))
      
      // Return index.html with 200 status for SPA routes
      return new Response(response.body, {
        status: 200,
        statusText: 'OK',
        headers: {
          ...Object.fromEntries(response.headers),
          'Content-Type': 'text/html; charset=utf-8'
        }
      })
    } catch (fallbackError) {
      return new Response('Not Found', { 
        status: 404,
        headers: { 'Content-Type': 'text/plain' }
      })
    }
  }
}