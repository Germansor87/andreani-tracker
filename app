import streamlit as st
import pandas as pd
import requests
from bs4 import BeautifulSoup
import io

st.set_page_config(page_title="Seguimiento Andreani", layout="wide")
st.title("📦 Seguimiento de Envíos - Andreani")

def extraer_codigo(link):
    return link.strip().split("/")[-1]

def obtener_estado_envio(codigo):
    url = f"https://www.andreani.com/envio/{codigo}"
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        estado_tag = soup.find('span', class_='shipment-status')
        if estado_tag:
            return estado_tag.text.strip()
        else:
            return "No encontrado"
    except:
        return "Error al consultar"

uploaded_file = st.file_uploader("📁 Subí tu archivo Excel con los links de seguimiento", type=["xlsx"])

if uploaded_file is not None:
    df = pd.read_excel(uploaded_file)

    if 'Seguimiento' not in df.columns or 'Destinatario' not in df.columns:
        st.error("El archivo debe tener columnas 'Seguimiento' y 'Destinatario'.")
    else:
        df['Código'] = df['Seguimiento'].apply(extraer_codigo)
        df['Estado'] = df['Código'].apply(obtener_estado_envio)

        def resaltar_estado(val):
            return 'background-color: lightgreen' if 'entregado' in val.lower() else ''

        st.subheader("📋 Resultados")
        st.dataframe(df.style.applymap(resaltar_estado, subset=['Estado']), use_container_width=True)

        output = io.BytesIO()
        df.to_excel(output, index=False)

        st.download_button(
            label="⬇️ Descargar Excel actualizado",
            data=output.getvalue(),
            file_name="seguimiento_actualizado.xlsx",
            mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )
