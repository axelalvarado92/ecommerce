import React, { useState } from 'react';
import './App.css';

function App() {
  // 1. Estado del carrito
  const [cart, setCart] = useState([]);
  
  // 2. Estado de carga
  const [loading, setLoading] = useState(false);
  
  // 3. Estado de error
  const [error, setError] = useState(null);

  // 4. Definir productos
  const products = [
    { id: 1, name: "Laptop", price: 1200 },
    { id: 2, name: "Mouse", price: 25 },
    { id: 3, name: "Keyboard", price: 80 },
    { id: 4, name: "USB", price: 15 }
  ];

  // 5. Función para agregar al carrito (con API Gateway)
  const addToCart = async (product) => {
    setLoading(true);
    setError(null);

    try {
      // Reemplaza con tu URL de API Gateway
      const API_URL = 'https://br0d2h9fq9.execute-api.us-east-1.amazonaws.com/orders';

      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1
        })
      });

      if (!response.ok) {
        throw new Error(`Error: ${response.status} ${response.statusText}`);
      }

      const data = await response.json();

      // Actualiza el carrito localmente
      setCart([...cart, product]);

      console.log('Respuesta del servidor:', data);

    } catch (err) {
      setError(err.message);
      console.error('Error al agregar al carrito:', err);
    } finally {
      setLoading(false);
    }
  };

  // 6. Calcular total
  const total = cart.reduce((sum, item) => sum + item.price, 0);

  // 7. Retornar JSX
  return (
    <div className="App">
      <h1>Productos</h1>

      {/* Lista de productos */}
      {products.map((product) => (
        <div key={product.id} className="product-card">
          <h3>{product.name}</h3>
          <p>${product.price}</p>
          <button 
            onClick={() => addToCart(product)}
            disabled={loading}
          >
            {loading ? 'Agregando...' : 'Agregar al carrito'}
          </button>
        </div>
      ))}

      <h2>Carrito</h2>

      {/* Lista del carrito */}
      {cart.length > 0 ? (
        cart.map((item, index) => (
          <div key={index} className="cart-item">
            {item.name} - ${item.price}
          </div>
        ))
      ) : (
        <p>El carrito está vacío</p>
      )}

      <h3>Total: ${total}</h3>

      {/* Mostrar error si existe */}
      {error && (
        <div className="error-message">
          ❌ Error: {error}
        </div>
      )}
    </div>
  );
}

export default App;