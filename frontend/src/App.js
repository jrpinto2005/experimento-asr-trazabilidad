import React, { useState } from 'react';
import axios from 'axios';

function App() {
  // Estado para seleccionar el backend
  const [selectedBackend, setSelectedBackend] = useState('validacion');
  
  // Estado para las credenciales
  const [nombre, setNombre] = useState('');
  const [id, setId] = useState('');
  
  // Estado para los productos
  const [productos, setProductos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);

  // URLs de los backends (configurables via variables de entorno)
  const BACKEND_URLS = {
    validacion: process.env.REACT_APP_BACKEND_VALIDACION_URL || 'http://localhost:8080',
    sinValidacion: process.env.REACT_APP_BACKEND_SIN_VALIDACION_URL || 'http://localhost:8081'
  };

  const handleBackendChange = (backend) => {
    setSelectedBackend(backend);
    setError(null);
    setSuccess(null);
    setProductos([]);
  };

  const fetchProductos = async () => {
    setLoading(true);
    setError(null);
    setSuccess(null);

    try {
      const url = selectedBackend === 'validacion' 
        ? BACKEND_URLS.validacion 
        : BACKEND_URLS.sinValidacion;

      const headers = {};
      
      // Solo agregar headers si hay credenciales ingresadas
      if (nombre && id) {
        headers['X-Operario-Nombre'] = nombre;
        headers['X-Operario-Id'] = id;
      }

      const response = await axios.get(`${url}/productos`, { headers });
      
      setProductos(response.data);
      setSuccess(`✅ Se consultaron ${response.data.length} productos exitosamente`);
      
      if (selectedBackend === 'validacion') {
        setSuccess(success => success + ` (con validación de credenciales)`);
      } else {
        setSuccess(success => success + ` (sin validación de credenciales)`);
      }
    } catch (err) {
      console.error('Error al consultar productos:', err);
      
      if (err.response) {
        setError(`❌ Error ${err.response.status}: ${err.response.data.message || err.response.data.error || 'Error al consultar productos'}`);
      } else if (err.request) {
        setError('❌ No se pudo conectar con el backend. Verifica que el servidor esté corriendo.');
      } else {
        setError(`❌ Error: ${err.message}`);
      }
      setProductos([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Para el backend con validación, verificar que haya credenciales
    if (selectedBackend === 'validacion' && (!nombre || !id)) {
      setError('⚠️ El backend CON validación requiere nombre e ID del operario');
      return;
    }
    
    fetchProductos();
  };

  const handleTestSinCredenciales = () => {
    // Limpiar credenciales temporalmente
    const tempNombre = nombre;
    const tempId = id;
    
    setNombre('');
    setId('');
    
    // Hacer la petición sin credenciales
    setTimeout(() => {
      fetchProductos();
      // Restaurar credenciales
      setNombre(tempNombre);
      setId(tempId);
    }, 100);
  };

  return (
    <div className="App">
      <header>
        <h1>🏢 Sistema de Inventario</h1>
        <p>Experimento ASR - Trazabilidad de Operarios</p>
      </header>

      <div className="experiment-selector">
        <h2>Seleccionar Experimento</h2>
        <div className="backend-buttons">
          <button
            className={`backend-button validacion ${selectedBackend === 'validacion' ? 'active' : ''}`}
            onClick={() => handleBackendChange('validacion')}
          >
            ✅ Backend CON Validación
            <br />
            <small>Requiere credenciales válidas</small>
          </button>
          <button
            className={`backend-button sin-validacion ${selectedBackend === 'sinValidacion' ? 'active' : ''}`}
            onClick={() => handleBackendChange('sinValidacion')}
          >
            ⚠️ Backend SIN Validación
            <br />
            <small>No requiere credenciales</small>
          </button>
        </div>
      </div>

      <div className="credentials-form">
        <h2>👤 Credenciales del Operario</h2>
        
        {selectedBackend === 'validacion' && (
          <div className="alert alert-warning">
            ⚠️ El backend CON validación requiere nombre e ID válidos del operario
          </div>
        )}
        
        {selectedBackend === 'sinValidacion' && (
          <div className="alert alert-error">
            ⚠️ ADVERTENCIA: El backend SIN validación permite consultas sin credenciales
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="nombre">Nombre del Operario:</label>
            <input
              type="text"
              id="nombre"
              value={nombre}
              onChange={(e) => setNombre(e.target.value)}
              placeholder="Ej: Juan Perez"
            />
          </div>

          <div className="form-group">
            <label htmlFor="id">ID del Operario:</label>
            <input
              type="number"
              id="id"
              value={id}
              onChange={(e) => setId(e.target.value)}
              placeholder="Ej: 1"
            />
          </div>

          {error && <div className="alert alert-error">{error}</div>}
          {success && <div className="alert alert-success">{success}</div>}

          <div className="button-group">
            <button 
              type="submit" 
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? '⏳ Consultando...' : '🔍 Consultar Productos'}
            </button>

            {selectedBackend === 'sinValidacion' && (
              <button
                type="button"
                className="btn btn-primary"
                onClick={handleTestSinCredenciales}
                disabled={loading}
              >
                🔓 Consultar SIN Credenciales
              </button>
            )}
          </div>

          <div style={{ marginTop: '15px', fontSize: '0.9rem', color: '#666' }}>
            <strong>Operarios disponibles para pruebas:</strong>
            <ul style={{ marginTop: '10px', marginLeft: '20px' }}>
              <li>ID: 1 - Juan Perez</li>
              <li>ID: 2 - Maria Garcia</li>
              <li>ID: 3 - Carlos Rodriguez</li>
              <li>ID: 4 - Ana Martinez</li>
              <li>ID: 5 - Luis Hernandez</li>
            </ul>
          </div>
        </form>
      </div>

      {loading && <div className="loading">⏳ Cargando productos...</div>}

      {productos.length > 0 && (
        <div className="products-container">
          <h2>📦 Productos en Inventario ({productos.length})</h2>
          <div className="products-grid">
            {productos.map((producto) => (
              <div key={producto.id} className="product-card">
                <h3>{producto.nombre}</h3>
                <div className="product-info">
                  <div className="product-info-item">
                    <span className="product-info-label">ID:</span>
                    <span className="product-info-value">{producto.id}</span>
                  </div>
                  <div className="product-info-item">
                    <span className="product-info-label">Stock:</span>
                    <span className="product-stock">{producto.stock_disponible} unidades</span>
                  </div>
                  <div className="product-info-item">
                    <span className="product-info-label">Precio:</span>
                    <span className="product-price">${producto.precio}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {!loading && productos.length === 0 && success && (
        <div className="no-products">
          No hay productos en el inventario
        </div>
      )}
    </div>
  );
}

export default App;
