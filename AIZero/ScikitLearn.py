# ===== 1. MACHINE LEARNING TRADICIONAL =====
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# Cargar dataset
iris = load_iris()
X = iris.data
y = iris.target

# Dividir en entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Escalar los datos
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Crear y entrenar modelo
model = LogisticRegression(max_iter=200)
model.fit(X_train, y_train)

# Predecir
y_pred = model.predict(X_test)

print("Exactitud (scikit-learn):", accuracy_score(y_test, y_pred))
# ===== 2. DEEP LEARNING CON TENSORFLOW/KERAS =====
