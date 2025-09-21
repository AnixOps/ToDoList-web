/**
 * Cloudflare Worker for serving static assets without KV dependency
 * This worker serves the built Vue.js SPA directly from the assets directory
 */

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const pathname = url.pathname
  
  try {
    // For SPA routing - serve index.html for routes that don't have file extensions
    // This handles client-side routing for Vue Router
    if (!pathname.includes('.') && pathname !== '/') {
      // Get the index.html file for SPA routing
      const indexUrl = new URL('/index.html', request.url)
      const indexRequest = new Request(indexUrl, {
        method: request.method,
        headers: request.headers,
      })
      return await fetch(indexRequest)
    }
    
    // For static assets (CSS, JS, images, etc.) and root path
    return await fetch(request)
    
  } catch (error) {
    // Fallback to index.html if asset not found (for SPA routing)
    try {
      const indexUrl = new URL('/index.html', request.url)
      const indexRequest = new Request(indexUrl, {
        method: 'GET',
        headers: request.headers,
      })
      const response = await fetch(indexRequest)
      
      // Return index.html with 200 status for SPA routes
      return new Response(response.body, {
        status: 200,
        statusText: 'OK',
        headers: {
          ...response.headers,
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