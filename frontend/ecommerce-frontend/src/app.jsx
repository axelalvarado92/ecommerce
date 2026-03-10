import { useState } from "react";
import "./amplifyConfig";
import Login from "./login";
import { createOrder } from "./api";

function App() {

  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const handleCreateOrder = async () => {
    const result = await createOrder();
    console.log(result);
    alert(JSON.stringify(result));
  };

  if (!isLoggedIn) {
    return <Login onLogin={()=>setIsLoggedIn(true)} />;
  }

  return (
    <div>

      <h1>Orders System</h1>

      <button onClick={handleCreateOrder}>
        Crear orden
      </button>

    </div>
  );
}

export default App;